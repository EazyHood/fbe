import json
import pathlib
import subprocess

config = json.loads(pathlib.Path('.github/validation/mutations.json').read_text())
command = ['bundle', 'exec', 'ruby', '-Itest', config['test'], '--', '--no-cov']
baseline = subprocess.run(command, text=True, capture_output=True)
print(baseline.stdout, flush=True)
assert baseline.returncode == 0, baseline.stderr
for mutation in config['mutations']:
    old, new, occurrence = mutation[:3]
    source = pathlib.Path(mutation[3] if len(mutation) > 3 else config['source'])
    original = source.read_text()
    pieces = original.split(old)
    assert len(pieces) > occurrence + 1, mutation
    changed = old.join(pieces[:occurrence + 1]) + new + old.join(pieces[occurrence + 1:])
    try:
        source.write_text(changed)
        result = subprocess.run(command, text=True, capture_output=True)
        print(f'MUTATION {mutation!r}\n{result.stdout}\n{result.stderr}', flush=True)
        assert result.returncode != 0, f'Undetected mutation: {mutation!r}'
        assert 'SyntaxError' not in result.stderr, 'Mutation must remain syntactically valid'
    finally:
        source.write_text(original)
print(f"Detected all {len(config['mutations'])} mutations", flush=True)
