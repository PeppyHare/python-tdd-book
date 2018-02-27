import json
import os
from collections import namedtuple
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager
from ansible.inventory.manager import InventoryManager
from ansible.playbook.play import Play
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.plugins.callback import CallbackBase
from ansible.utils.display import Display
from ansible.plugins.callback.debug import CallbackModule as CallbackModule_default


def execute_ansible_play(play_source):
    Options = namedtuple('Options', [
        'connection', 'module_path', 'forks', 'become', 'become_method',
        'become_user', 'check', 'diff', 'remote_user',
        'ansible_python_interpreter'
    ])
    # initialize needed objects
    loader = DataLoader()
    dir = os.path.abspath(__file__)
    project_dir = os.path.normpath(os.path.join(dir, '../..'))
    module_path = os.sep.join(
        [project_dir, 'venv', 'lib', 'python3.6', 'site-packages'])
    options = Options(
        connection='smart',
        module_path=module_path,
        forks=100,
        become=True,
        become_method='sudo',
        become_user='ubuntu',
        check=False,
        diff=False,
        remote_user='ubuntu',
        ansible_python_interpreter='/usr/bin/python3')
    vault_pass_file = os.environ.get('ANSIBLE_VAULT_PASSWORD_FILE')
    with open(vault_pass_file) as f:
        p = f.readline().strip()
    passwords = dict(vault_pass=p)

    # Instantiate our ResultCallback for handling results as they come in
    results_callback = CallbackModule_default()
    # create inventory and pass to var manager
    inventory = InventoryManager(
        loader=loader, sources=['superlists-staging.peppyhare.uk,'])
    variable_manager = VariableManager(loader=loader, inventory=inventory)

    play = Play().load(
        play_source, variable_manager=variable_manager, loader=loader)
    # actually run it
    tqm = None
    try:
        tqm = TaskQueueManager(
            inventory=inventory,
            variable_manager=variable_manager,
            loader=loader,
            options=options,
            passwords=passwords,
            stdout_callback=results_callback,
        )
        tqm.display = Display(verbosity=5)
        result = tqm.run(play)
    finally:
        if tqm is not None:
            tqm.cleanup()


def reset_database(host):
    # create play with tasks
    play_source = dict(
        name="Ansible Play",
        hosts='superlists-staging.peppyhare.uk',
        gather_facts='no',
        tasks=[
            dict(
                name="Run shell script",
                action=dict(module='shell', args='ls'),
                register='shell_out'),
            dict(
                name="Reset sqlite database",
                action=dict(
                    module='docker_container',
                    args=dict(
                        image='pythontddbook_django',
                        name='pythontddbook_resetdb',
                        auto_remove='yes',
                        volumes='pythontddbook_django-db:/app/db.sqlite3',
                        command='/venv/bin/python /app/manage.py flush --noinput'
                    )))
        ])

    execute_ansible_play(play_source)
