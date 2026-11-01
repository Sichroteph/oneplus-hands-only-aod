"""Decode one MCU_FILE_BASE64 response without changing the device."""
import argparse,base64,hashlib,re
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('log',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
s=a.log.read_text(encoding='utf-8-sig')
m=re.findall(r'^MCU_FILE_BASE64 ([A-Za-z0-9+/=]+)\s*$',s,re.M)
if len(m)!=1:p.error('Expected exactly one complete native-file response')
b=base64.b64decode(m[0],validate=True)
a.output.parent.mkdir(parents=True,exist_ok=True)
with a.output.open('xb') as f:f.write(b)
print(len(b),'bytes; SHA256',hashlib.sha256(b).hexdigest())
