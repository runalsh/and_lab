script can filter snapshots from aws cli by date or\and Value Tag or \and Region and can copy and remove it

At first you shoild install AWS CLI https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html and add you secuirity creds to PATH

Usage: ./aws_cli.sh [-y years][-m month][-d days][-h hours][-min minutes][-o owner][-r region][-tv tagvalue][-v verbose]

  -y|--years   years before creating snapshot. Default: null
  
  -m|--month    months before creating snapshot. Default: null
  
  -d|--days    days before creating snapshot. Default: null
  
  -h|--hours    hours before creating snapshot. Default: null
  
  -min|--minutes    minutes before creating snapshot. Default: null
  
  -o|--owner   owner of snapshot. Default: self
  
  -r|--region   region of snapshot. Default: eu-central-1
  
  -o|--tagvalue  Value of Tag  of snapshot. Default: null
  
  -v|--verbose     Optional. Logging on. By default off  (Ex: -v or dont use)
  
Example: ./aws_cli.sh [-h 1] [-m 23] [-o userowner][-t snap-] [-v]
