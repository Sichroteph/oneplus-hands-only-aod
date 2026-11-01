"""Build a known hands-only candidate locally. Does not connect to any watch."""
import argparse, hashlib, json, re
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--recipe', required=True, type=Path)
p.add_argument('--original', required=True, type=Path)
p.add_argument('--native-path', required=True, help='Independently identified on YOUR watch')
p.add_argument('--out', required=True, type=Path)
a=p.parse_args()
if not re.fullmatch(r'/wf/wf[0-9]{1,2}/aod/script/main\.js',a.native_path):
    p.error('Unsupported native path')
r=json.loads(a.recipe.read_text(encoding='utf-8-sig'))
data=a.original.read_bytes()
sha=lambda b:hashlib.sha256(b).hexdigest()
if sha(data)!=r['original_sha256']:p.error('Unrecognized original. Do not bypass the hash guard.')
lines=data.decode('utf-8').splitlines(keepends=True)
for edit in reversed(r['edits']):
    lines[edit['start_line']:edit['end_line']]=[edit['replacement']]
candidate=''.join(lines).encode('utf-8')
if sha(candidate)!=r['candidate_sha256']:p.error('Generated candidate hash mismatch')
names=['original-main.js','candidate-main.js','manifest.json']
if any((a.out/n).exists() for n in names):p.error('Output already contains case files; use a new directory')
a.out.mkdir(parents=True,exist_ok=True)
(a.out/names[0]).write_bytes(data)
(a.out/names[1]).write_bytes(candidate)
m={k:r[k] for k in ['model','build','package','versionCode','versionName','uuid','original_sha256','candidate_sha256']}
m.update(native_path=a.native_path,original_file=names[0],candidate_file=names[1])
(a.out/names[2]).write_text(json.dumps(m,indent=2)+'\n',encoding='utf-8')
print('Local candidate verified:',r['candidate_sha256'])
print('No device was contacted. Verify identity, resource mapping and backups before installation.')
