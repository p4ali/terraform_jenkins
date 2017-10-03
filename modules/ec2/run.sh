#!/usr/bin/env bash

help_and_exit () {
 echo "Usage: $0 init|plan|apply|destroy"
 exit 1
}

if [ $# -ne 1 ]; then
      help_and_exit $0
fi

exes=( git go terraform )
for i in "${exes[@]}"
do
	command -v $i >/dev/null 2>&1 || { echo "$i is not installed.  Aborting." >&2; exit 1; }
done

if [ ! -s ../terraform.tfvars ]; then
  echo "../terraform.tfvars does not exist. Aborting." >&2;
  exit 1
fi

echo "[$1]"

case "$1" in

init)
      terraform init -var-file=../terraform.tfvars
      ;;
plan)
      terraform plan -var-file=../terraform.tfvars
      ;;
apply)
      terraform apply -var-file=../terraform.tfvars
      ;;
destroy)
      terraform destroy -force -var-file=../terraform.tfvars
      ;;
*)
      help_and_exit $0
      ;;
esac