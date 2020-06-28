## Netboot Buildroot

#### Build kernel + initrd

```bash
docker run -v $PWD:/build -w /build -it ljfranklin/netboot-buildroot build.sh raspberrypi3_64_custom_defconfig
```

#### Update buildroot dep

```bash
git subtree pull --prefix deps/buildroot https://github.com/buildroot/buildroot master --squash
```
