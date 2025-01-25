## OpenWRT build's

0. clone openwrt git

```bash
git clone https://github.com/pesa1234/openwrt && cd openwrt
```

1. clone this repository in ./bin/ folder

```bash
mkdir -p bin && pushd bin && git clone https://github.com/Ogglord/MT6000_cust_build.git . && popd
```

2. apply patches
3. link files (```ln -s ./bin/files files```)
4. build

```bash
./bin/build.sh full
```
