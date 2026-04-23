#!/usr/bin/env python3
import os, sys, re, html, urllib.request, json, pathlib, concurrent.futures

BASE = 'https://www.linuxfromscratch.org/lfs/view/stable/'
CHAPTERS = {
    'chapter05': 'ch5-toolchain',
    'chapter06': 'ch6-crosstools',
    'chapter07': 'ch7-chroot-tools',
    'chapter08': 'ch8-system',
    'chapter09': 'ch9-config',
    'chapter10': 'ch10-boot',
}

def fetch(url):
    req = urllib.request.Request(url, headers={'User-Agent':'Mozilla/5.0'})
    return urllib.request.urlopen(req, timeout=20).read().decode('utf-8', 'replace')

def extract_cmds(h):
    return [html.unescape(re.sub(r'<[^>]+>', '', m.group(1))).strip()
            for m in re.finditer(r'<pre[^>]*class="userinput"[^>]*>(.*?)</pre>', h, re.DOTALL)]

def pagelist():
    idx = fetch(BASE + 'index.html')
    seen=set(); out=[]
    for l in re.findall(r'href="(chapter\d+/[^"]+\.html)"', idx):
        if l not in seen: seen.add(l); out.append(l)
    return out

def work(page):
    chap, slug = page.split('/',1); slug = slug.replace('.html','')
    if chap not in CHAPTERS: return None
    url = BASE+page
    for attempt in range(3):
        try:
            data = fetch(url); break
        except Exception as e:
            if attempt==2: print("FAIL",url,e,file=sys.stderr); return None
    cmds = extract_cmds(data)
    return (CHAPTERS[chap], slug, url, cmds)

def main():
    outdir = pathlib.Path(sys.argv[1]); outdir.mkdir(parents=True, exist_ok=True)
    pages = pagelist()
    results=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as ex:
        for r in ex.map(work, pages):
            if r: results.append(r)
    for subdir, slug, url, cmds in results:
        sub = outdir/subdir; sub.mkdir(parents=True, exist_ok=True)
        p = sub/f'{slug}.cmds'
        with open(p,'w') as f:
            f.write(f'# source: {url}\n\n')
            for c in cmds: f.write(c+'\n\n')
    print(f"wrote {len(results)} pages")

if __name__=='__main__': main()
