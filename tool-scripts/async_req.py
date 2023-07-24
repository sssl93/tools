import asyncio, aiohttp, time

error = 0
ok = 0
status_summary = {}


async def fetch(url, method, params=None, data=None):
    global error, ok
    async with aiohttp.ClientSession() as s:
        try:
            async with s.request(method, url, params=params, json=data) as r:
                status_summary[r.status] = status_summary.get(r.status, 0) + 1
        except Exception as e:
            error += 1
            print(e)


_url = "http://192.168.110.102"
_url = "http://192.168.99.100:9014/reset-flow"
_method = "POST"

tasks = []
for i in range(1000):
    tasks.append(fetch(_url, _method))

event_loop = asyncio.get_event_loop()
start = time.time()
results = event_loop.run_until_complete(asyncio.gather(*tasks))
print('error: ', error)
print(status_summary)
print('time: ', time.time() - start)
event_loop.close()
