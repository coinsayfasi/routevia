import json,sys,os,urllib.request,urllib.error
REF="xfswonqskciufcnsehfc"
PAT=os.environ["SUPA_PAT"]
q=open(sys.argv[1]).read()
req=urllib.request.Request(f"https://api.supabase.com/v1/projects/{REF}/database/query",
  data=json.dumps({"query":q}).encode(),
  headers={"Authorization":f"Bearer {PAT}","Content-Type":"application/json","User-Agent":"curl/8.4.0"})
try:
    print(urllib.request.urlopen(req).read().decode())
except urllib.error.HTTPError as e:
    print("HTTPERROR",e.code,e.read().decode()); sys.exit(1)
