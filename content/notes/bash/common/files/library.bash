#!/usr/bin/env bash

# set -e
# set -o pipefail

# __library_geoip() {
#   curl -s --connect-timeout 3 "http://ip-api.com/json/${1:-}?fields=continent,countryCode,country,regionName,city,district,query,isp,org,as,asname,currency,timezone,mobile,proxy,hosting" | jq .
# }
# __library_edns() {
#   curl -sL --connect-timeout 3 http://edns.ip-api.com/json
# }
# __library_batch() {
#   local ips='['
#   for i in "$@"; do
#     ips="${ips}\"${i}\", "
#   done
#   ips=$(echo "${ips}" | sed 's/, $/]/')
#   curl -s --connect-timeout 3 'http://ip-api.com/batch?fields=continent,countryCode,country,regionName,city,district,query,isp,org,as,asname,currency,timezone,mobile,proxy,hosting' --data "${ips}" | jq .

# }
# geoip() {
#   declare -r baseName="$0"
#   printHelp() {
#     echo "Display GeoIP"
#     echo "Usage: ${baseName} [IP]"
#     echo "Usage: ${baseName} [IP1] [IP2] ..."
#     echo "Usage: ${baseName} edns"
#   }
#   local param="${1}"
#   if [[ "$#" -lt 1 ]]; then
#     __library_geoip
#   elif [[ "$#" -eq 1 ]]; then
#     if [[ "${param}" == "-h" || "${param}" == "--help" ]]; then
#       printHelp
#     elif [[ "${param}" == "edns" || "${param}" == "dns" ]]; then
#       __library_edns
#     else
#       __library_geoip "${param}"
#     fi
#   elif [[ "$#" -ge "2" ]]; then
#     __library_batch "$@"
#   else
#     printHelp
#   fi
# }

# __library_encodes() {
#   printf "${1}" | base91 | base91 | base91 | base91 | base91 | base91 | base64
# }
# __library_decodes() {
#   printf "${1}" | base64 -d | base91 -d | base91 -d | base91 -d | base91 -d | base91 -d | base91 -d
# }
# encodes() {
#   local param="$1"
#   local decodeString="$2"
#   declare -r baseName="$0"
#   printHelp() {
#     echo "Encode parameters"
#     echo "Usage: ${baseName} [option] [string]"
#     echo ""
#     echo "Option:"
#     echo "    -d decode"
#   }
#   if [[ "${param}" == "-h" || "${param}" == "--help" ]]; then
#     printHelp
#   ## Decode
#   elif [[ "${param}" == "-d" ]]; then
#     local decodeResult=$(__library_decodes "${decodeString}")
#     printf "${decodeResult}" | pbcopy
#     echo "${decodeResult}"
#   ## Encode
#   elif [[ "${param}" != "" && "${param}" != "-d" ]]; then
#     local encodeLong=$(__library_encodes "${param}")
#     printf "${encodeLong}" | pbcopy
#     echo "${encodeLong}"
#   else
#     printHelp
#     # echo "No valid string!"
#     # zsh -c 'exit 1'
#   fi
# }

# __library_hashes() {
#   # base64 | shasum -a 512224 -b | base91 | shasum -a 512256
#   printf "${1:-}$(head -c 16 /dev/random)" | git hash-object --stdin
# }
# hashes() {
#   local param="$@"
#   declare -r baseName="$0"
#   printHelp() {
#     echo "Hash parameters"
#     echo "Usage: ${baseName} [string]"
#   }
#   if [[ "${param}" == "-h" || "${param}" == "--help" ]]; then
#     printHelp
#   else
#     local hashLong=$(__library_hashes "${param}")
#     local hashShort="${hashLong:0:16}"
#     printf "${hashShort}" | pbcopy
#     echo "${hashShort}"
#   fi
# }

__library_gitpull() {
  local currentDir="${PWD}"
  local logFile='/tmp/git.log'
  if [[ -e "${logFile}" ]]; then
    rm -f "${logFile}"
  fi
  date >"${logFile}"
  . /usr/local/bin/status
  for g in work git; do
    for dir in ~/${g}/*/; do
      dir=$(echo -n "${dir}" | sed 's/\/$//')
      cd "${dir}"
      msg "${YELLOW}[$(basename "${dir}")]${RESET}($(pwd))" >>"${logFile}" 2>&1
      git rev-parse --abbrev-ref HEAD >>"${logFile}" 2>&1
      git pull >>"${logFile}" 2>&1
      git submodule update --init --remote >>"${logFile}" 2>&1
      echo "" >>"${logFile}" 2>&1
    done
  done
  clear
  cd "${currentDir}"
}
__library_extensions() {
  export GOPATH="${HOME}/.go"
  # export LANG=en_US.UTF-8
  export NVM_DIR="${HOME}/.nvm"
  ## Define PATH
  if [[ $(uname -s) == "Darwin" ]]; then
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/sbin:/Library/Frameworks/Mono.framework/Versions/Current/Commands:${GOPATH}/bin:${HOME}/Library/Python/3.9/bin"
    ## The next line updates PATH for the Google Cloud SDK.
    . "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
    ## The next line enables shell command completion for gcloud.
    . "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
  else
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/sbin:${GOPATH}/bin"
  fi
  ## This loads nvm
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"
  ## This loads nvm bash_completion
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"
  ## Install dependencies
  if ! which git-split-diffs >/dev/null 2>&1; then
    ## https://github.com/banga/git-split-diffs
    zsh -c 'npm install -g git-split-diffs@0.10.0'
  fi
  if ! which markdownlint >/dev/null 2>&1; then
    ## https://github.com/igorshubovych/markdownlint-cli
    zsh -c 'npm install -g markdownlint-cli@0.31.1'
  fi
  if ! which dunk >/dev/null 2>&1; then
    ## https://github.com/darrenburns/dunk
    zsh -c 'pip3 install dunk'
  fi
  if ! stat ~/.gem/ruby/3.1.3 >/dev/null 2>&1; then
    ruby-install ruby 3.1.3
    source "$(brew --prefix)/opt/chruby/share/chruby/chruby.sh"
    source "$(brew --prefix)/opt/chruby/share/chruby/auto.sh"
    chruby ruby-3.1.3
    gem install jekyll
  fi
  source "$(brew --prefix)/opt/chruby/share/chruby/chruby.sh"
  source "$(brew --prefix)/opt/chruby/share/chruby/auto.sh"
  chruby ruby-3.1.3
}
__library_aliases() {
  if which ops-cli >/dev/null 2>&1; then
    alias arping='sudo ops-cli arping'
    alias cert='ops-cli cert'
    alias convert='ops-cli convert'
    alias date='ops-cli date'
    alias df='ops-cli df'
    alias dig='ops-cli dig'
    alias dos2unix='ops-cli dos2unix'
    alias encode='ops-cli encode'
    alias encrypt='ops-cli encrypt'
    alias free='ops-cli free'
    alias geoip='ops-cli geoip'
    alias hash='ops-cli hash'
    alias icp='ops-cli icp'
    alias ip='ops-cli ip'
    alias mtr='sudo ops-cli mtr'
    alias netmask='ops-cli netmask'
    alias otp='ops-cli otp'
    # alias ping='sudo ops-cli ping'
    alias qrcode='ops-cli qrcode'
    alias random='ops-cli random'
    alias redis='ops-cli redis'
    alias stat='ops-cli stat'
    alias tcping='ops-cli tcping'
    alias traceroute='sudo ops-cli traceroute'
    alias tree='ops-cli tree'
    alias whois='ops-cli whois'
    alias wsping='ops-cli wsping'
  fi
  alias backup_brew='brew bundle dump --describe --force --file="~/git/terminal_config/macos/Brewfile"'
  alias changeMACaddress='networksetup -setairportpower en0 off && networksetup -setairportpower en0 on && sudo ifconfig en0 ether 90:9c:4a:d2:d7:25 && sleep 5 && networksetup -setairportnetwork en0 Tstar5 && ifconfig en0 | grep ether | awk "{print \$2}"'
  alias colorPrint='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+"\n"}; done'
  # alias diff='diff -y --suppress-common-lines'
  alias flushdns='sudo killall -HUP mDNSResponder;sudo killall mDNSResponderHelper;sudo dscacheutil -flushcache'
  alias gf='git diff | dunk | less -R'
  alias gfl='git diff | git-split-diffs --color | less -RFX'
  alias gg='git log -p | git-split-diffs --color | less -RFX'
  alias gitpull='__library_gitpull'
  # alias k='kubectl'
  # alias kc='kubecm'
  alias list_npm_package='npm list -g --depth=0'
  alias localip='for ip in $(ifconfig -l);do addr=$(ipconfig getifaddr ${ip});if [ "$(ipconfig getifaddr $ip;echo $?)" != 1 ];then echo $ip: $addr;fi;done'
  alias oracle='ssh ubuntu@129.146.77.155'
  alias port_established='lsof -PRlni4TCP|awk /ESTABLISHED/'
  alias port_listen='lsof -PRlni4TCP|awk /LISTEN/'
  alias proxy="
    export http_proxy=socks5://127.0.0.1:9050;
    export HTTP_PROXY=socks5://127.0.0.1:9050;
    export https_proxy=socks5://127.0.0.1:9050;
    export HTTPS_PROXY=socks5://127.0.0.1:9050;
    export SSH_proxy=socks5://127.0.0.1:9050;
    export SSH_PROXY=socks5://127.0.0.1:9050;
    export all_proxy=socks5://127.0.0.1:9050;
    export ALL_PROXY=socks5://127.0.0.1:9050;
    export no_proxy=socks5://127.0.0.1:9050;
    export NO_PROXY=socks5://127.0.0.1:9050;"
  alias restoreMACaddress='networksetup -setairportpower en0 off && networksetup -setairportpower en0 on && sudo ifconfig en0 ether f0:18:98:3c:c5:89 && sleep 5 && networksetup -setairportnetwork en0 Tstar5 && ifconfig en0 | grep ether | awk "{print \$2}"'
  alias restore_brew='brew bundle --file="~/git/terminal_config/macos/Brewfile"'
  alias routing='netstat -rf inet'
  if [[ -f '/usr/local/bin/sudo' ]]; then
    alias sudo='/usr/local/bin/sudo'
  fi
  alias tabby="docker run -u $(id -u) -d --name tabby -p 8080:8080 -v $HOME/.tabby:/data ghcr.io/tabbyml/tabby serve --model TabbyML/SantaCoder-1B"
  alias tojson='yq eval -j'
  alias toyaml='yq eval -P'
  alias unproxy="
    unset http_proxy;
    unset HTTP_PROXY;
    unset https_proxy;
    unset HTTPS_PROXY;
    unset ssh_proxy;
    unset SSH_PROXY;
    unset all_proxy;
    unset ALL_PROXY;
    unset no_proxy;
    unset NO_PROXY;"
  alias weather='curl wttr.in'
}

__library_extensions
__library_aliases
