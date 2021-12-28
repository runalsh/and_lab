#!/bin/bash


#make sure aws configuration 


#set default
years=0
month=0
days=0
hours=0
minutes=0
owner="self"
region="eu-central-1"
tagvalue=""

#удалить  после теста, берем из ключей
#tagvaluekey="kukukuku"

function usage() {
  if [ -n "$1" ]; then
    echo -e "${RED} $1${CLEAR}\n";
  fi
  echo "script can filter snapshots from aws cli by date or\and Value Tag or \and Region and can copy and remove it"
  echo "Usage: $0 [-y years][-m month][-d days][-h hours][-min minutes][-o owner][-r region][-tv tagvalue][-v verbose]"
  echo "  -y|--years   years before creating snapshot. Default: null"
  echo "  -m|--month    months before creating snapshot. Default: null"
  echo "  -d|--days    days before creating snapshot. Default: null"
  echo "  -h|--hours    hours before creating snapshot. Default: null"
  echo "  -min|--minutes    minutes before creating snapshot. Default: null"
  echo "  -o|--owner   owner of snapshot. Default: self"
  echo "  -r|--region   region of snapshot. Default: eu-central-1"
  echo "  -o|--tagvalue  Value of Tag  of snapshot. Default: null"  
   echo "  -v|--verbose     Optional. Logging on. By default off  (Ex: -v or dont use)"
  echo "Example: $0 [-h 1] [-m 23] [-o userowner][-t snap-] [-v]"  
  echo ""
  exit 1
}

#read keys
#get args
while [[ "$#" > 0 ]]; do case $1 in
  -y|--years) years="$2"; shift;shift;;
  -m|--month) month="$2";shift;shift;;
  -d|--days) days="$2";shift;shift;;
  -h|--hours) hours="$2";shift;shift;;  
  -min|--minutes) minutes="$2";shift;shift;;  
  -o|--owner) owner="$2";shift;shift;;  
  -r|--region) region="$2";shift;shift;;  
  -tv|--tagvalue) tagvalue="$2";shift;shift;;  
   -v|--verbose) set -x	;shift;;
  *) usage "Unknown parameter: $1"; shift; shift;;
esac; 
done

#kuku="$(aws ec2 describe-snapshots --region "$region" --owner-ids "$owner" --query "Snapshots[?(StartTime>='$date_mod')].{SnapshotId:SnapshotId,StartTime:StartTime,VolumeSize:VolumeSize}" --query "reverse(sort_by(Snapshots,&StartTime))[$SNAPSHOTS_PERIOD:].[SnapshotId,StartTime]"  --output table)"

#valuenotnull="--filters "Name=tag-value,Values=$tagvalue""

if [ "$tagvaluekey" != "$tagvalue" ]; then 
tagvalue=$tagvaluekey && valuenotnull="--filters "Name=tag-value,Values=$tagvalue"" && descrvaluetags="with Value in Tags $tagvalue"
else valuenotnull="" && descrvaluetags=""
fi  

#check for null date
let "checkfornulldate=$years+$month+$days+$hours+$minutes"
#echo $checkfornulldate
if [ $checkfornulldate -eq 0 ]; then
date_mod="$date"
else 
date_mod="$(date --date="-$years years -$month months -$days days -$hours hours -$minutes minutes" +%Y-%m-%dT%H:%M:%S)"
fi
# echo $checkfornulldate

#generate date
#date_mod="$(date --date="-$years years -$month months -$days days -$hours hours -$minutes minutes" +%Y-%m-%dT%H:%M:%S)"
#echo $date_mod

#echo $valuenotnull 
echo "Selected ELB Snapshots in region $region created before $date_mod $descrvaluetags"

aws ec2 describe-snapshots --region "$region" --owner-ids "$owner" $valuenotnull --query 'sort_by(Snapshots, &StartTime)' --query "Snapshots[?(StartTime>='$date_mod')].{StartTime:StartTime, SnapshotId:SnapshotId, VolumeSize:VolumeSize}" 

read -p "Will copy snapshots to s3 storage? (y/n) or (yes/no): " copytos3
case $copytos3 in
	"y"|"yes")
		snapshots_massive=()
		while read -p "SnapshotID (your can copy drom above table):" snapshotsid; do
			snapshots_massive+=($snapshotsid)
			read -p "add more snaps? (y/n) or (yes/no): " addmoresnaps
					case $addmoresnaps in
						"yes"|"y")
									continue
									;;
						"no"|"n")
									break
					esac
		done
		read -p "destination region  (ex: eu-central-1, us-west-2):" destinationreg
		for snapshotsid in ${snapshots_massive[@]}; do
					aws ec2 copy-snapshot --source-region "$region" --source-snapshot-id "$snapshotsid" --region "$destinationreg"
					echo "you can check it https://s3.console.aws.amazon.com/s3/home?region=$destinationreg"
				done
					;;
	"n"|"no")
			 #exit 0
			 break
esac

read -p "do you want remove snapshots? (y/n) or (yes/no): " removesnaps
case $removesnaps in
"y"|"yes")
		snapshotsremove_massive=()
		while read -p "WARNING! ITS REMOVE SNAPSHOTS! DO backup before! SnapshotID to remove (your can copy from above table):" snapshotsremoveid; do
			snapshotsremove_massive+=($snapshotsremoveid)
			read -p "add more snaps TO REMOVE? (y/n) or (yes/no): " addmoresnapstoremove
					case $addmoresnapstoremove in
						"yes"|"y")
									continue
									;;
						"no"|"n")
									break
					esac
		done
		for snapshotsremoveid in ${snapshotsremove_massive[@]}; do
					aws ec2 delete-snapshot --snapshot-id $snapshotsremoveid
					echo "snapshot $snapshotsremoveid already removed"
				done
					;;
	"n"|"no")
			 exit 0
esac

