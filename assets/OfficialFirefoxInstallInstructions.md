# Install Firefox .deb package for Debian-based distributions (recommended)

## To install the .deb package through the APT repository, do the following:

1. Create a directory to store APT repository keys if it doesn't exist:

```
sudo install -d -m 0755 /etc/apt/keyrings
```

2. Import the Mozilla APT repository signing key:

```
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
```
If you do not have wget installed, you can install it with: sudo apt-get install wget

3. The fingerprint should be 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3. You may check it with the following command:

```
gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
```

4. Next, add the Mozilla APT repository to your sources.list:
    For Debian Bookworm (Ubuntu 22.04 runs this) and Older: 

```
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
```

    For Debian Trixie and Newer 

```
cat <<EOF | sudo tee /etc/apt/sources.list.d/mozilla.sources
Types: deb
URIs: https://packages.mozilla.org/apt
Suites: mozilla
Components: main
Signed-By: /etc/apt/keyrings/packages.mozilla.org.asc
EOF
```

5. Configure APT to prioritize packages from the Mozilla repository:

```
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
```

6. Update your package list, and install firefox (or one of firefox-esr, -beta, -nightly, -devedition):

sudo apt-get update && sudo apt-get install firefox