from fabric.api import run
from fabric.context_managers import settings, shell_env

FABRIC_SSH_USER = 'ubuntu'


def _get_server_env_vars():
    env_lines = run(
        f'cat /home/ubuntu/GitHub/python-tdd-book/.env'.splitlines())
    return dict(l.split('=') for l in env_lines if l)


def reset_database(host):
    with settings(host_string=f'{FABRIC_SSH_USER}@{host}'):
        docker_run_opts = [
            '--rm', '--name pythontddbook_resetdb',
            '-v pythontddbook_django-db:/app/db.sqlite3'
        ]
        docker_container = 'pythontddbook_django_1'
        docker_cmd = '/venv/bin/python /app/manage.py flush --noinput'
        run(f'docker exec {docker_container} {docker_cmd}')


def create_session_on_server(host, email):
    with settings(host_string=f'{FABRIC_SSH_USER}@{host}'):
        env_vars = _get_server_env_vars()
        with shell_env(**env_vars):
            import pdb
            pdb.set_trace()
            session_key = run(
                f'docker-compose -f /home/ubuntu/GitHub/python-tdd-book/docker-compose.yml exec django /venv/bin/python /app/manage.py create_session {email}'
            )
            return session_key.strip()
