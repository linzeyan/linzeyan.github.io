#!/bin/bash

index=${index:-backup}
es_addr='{{ es_addr }}'
base_dir='{{ datapath }}'
data_file='master.info'

check () {
  status=$(curl --connect-timeout 5 -so /dev/null -w %{http_code} ${es_addr}/${index})
  if [ ${status} == 200 ];then
    echo 'Index present.'
    echo 'Update record...'
    bulk update
  elif [ ${status} == 404 ];then
    echo 'Index absent.'
    echo 'Create record...'
    bulk create
  else
    echo 'Something wrong.'
    exit 111
  fi
}

bulk () {
  head='Content-Type: application/json'
  tmp_file=$(mktemp -t elkbulk.XXXXXXXX)
  trap "rm -f ${tmp_file}" EXIT
  for site in $(ls ${base_dir})
  do
    filepath="${base_dir}/${site}/${data_file}"
    bin_name=$(awk 'NR==1{print $3}' ${filepath})
    bin_posi=$(awk 'NR==2{print $3}' ${filepath})
    req="{\"${1}\": { \"_index\": \"${index}\", \"_id\": \"${site}\"}}"
    if [ "${1}" == 'create' ];then
      data="{\"bin_name\": ${bin_name}, \"bin_pos\": ${bin_posi}}"
    elif [ "${1}" == 'update' ];then
      data="{\"doc\": {\"bin_name\": ${bin_name}, \"bin_pos\": ${bin_posi}}}"
    else
      data="{}"
    fi
    printf "${req}\n${data}\n" >> ${tmp_file}
  done

  curl -XPOST "${es_addr}/_bulk?pretty" -H "${head}" --data-binary "@${tmp_file}"
}

restore () {
  tmp_file=$(mktemp -t site.XXXXXXXX)
  trap "rm -f ${tmp_file}" EXIT
  curl -s "${es_addr}/${index}/_search?q=*&pretty" -o ${tmp_file}
  i=0
  for site in $(jq [.hits.hits[]._id] ${tmp_file}|awk '{print $1}'|sed -e '1d' -e '$d' -e 's/[\",]//g')
  do
    mkdir -p ${base_dir}/${site}
    filepath="${base_dir}/${site}/${data_file}"
    bin_name=$(jq [.hits.hits[${i}]._source.bin_name] ${tmp_file}|awk 'NR==2{print $1}')
    bin_posi=$(jq [.hits.hits[${i}]._source.bin_pos]  ${tmp_file}|awk 'NR==2{print $1}')
    printf "bin_name = ${bin_name}\nbin_pos = ${bin_posi}\n" > ${filepath}
    i=$((${i}+1))
  done
}

case $1 in
  backup)
        check
  ;;
  rescue)
        restore
  ;;
  *)
        echo "Usage: ${0} {backup|rescue}"
  ;;
esac
