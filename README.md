# 1. Install Docker

https://docs.docker.com/get-docker/

# 2. Build container

```
docker build --platform linux/amd64 -t proton .
```

# 3. Start Container

Replace `/Users/jafri` with your own working directory

```
docker run \
  -d \
  --name proton \
  --platform linux/amd64 \
  --user 0 \
  -v /Users/jafri:/Users/jafri \
  -v /Users/jafri/eosio-wallet:/root/eosio-wallet \
  -w /Users/jafri \
  -e HOME=/Users/jafri \
  proton
```

# 4. Open terminal

```
docker exec -it -u 0 proton /bin/sh
```

# 5. (Helper) View running containers

```
docker ps -a
```

# Credits
Thanks to @poplexity for the initial instructions!
