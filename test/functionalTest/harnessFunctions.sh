# Copyright 2013 Telefonica Investigacion y Desarrollo, S.A.U
#
# This file is part of Orion Context Broker.
#
# Orion Context Broker is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Orion Context Broker is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
# General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Orion Context Broker. If not, see http://www.gnu.org/licenses/.
#
# For those usages not covered by this license please contact with
# iot_support at tid dot es

# ------------------------------------------------------------------------------
#
# harnessInit - 
#

if [ "$CONTEXTBROKER_TESTENV_SOURCED" != "YES" ]
then
  echo
  echo '---------------------------------------------------'
  echo "Test Environment missing - please source testEnv.sh"
  echo '---------------------------------------------------'
  echo
  exit 1
fi

export CONTEXTBROKER_HARNESS_FUNCTIONS_SOURCED="YES"

if [ "$ORION_FT_DEBUG" == "1" ]
then
  _debug='on'
else
  _debug='off'
fi



# ------------------------------------------------------------------------------
#
# harnessExit - 
#
function harnessExit()
{
  rm -f headers.out
}



# ------------------------------------------------------------------------------
#
# vMsg - verbose output
#
# Remember that if the '--verbose' flag is used, the verboser messages pollute
# the total answer and the harness test will fail.
#
# Verbose mode is only meant to troubleshoot harness tests that fail.
#
function vMsg()
{
  if [ "$_verbose" == "on" ]
  then
    echo $*
  fi
}



# ------------------------------------------------------------------------------
#
# dMsg - debug output
#
function dMsg()
{
  if [ "$ORION_FT_DEBUG" == 1 ] || [ "$_debug" == "on"  ]
  then
    echo $* >> /tmp/orionFuncTestDebug.log
  fi
}



# ------------------------------------------------------------------------------
#
# dbInit - 
#
function dbInit()
{
  role=$1
  
  host="${CB_DATABASE_HOST}"
  if [ "$host" == "" ]
  then
    host="localhost"
  fi
  
  port="${CB_DATABASE_PORT}"
  if [ "$port" == "" ]
  then
    port="27017"
  fi
  
  db=$host:$port/$1

  dMsg initializing database;

  if [ "$role" == "CB" ]
  then
    echo 'db.dropDatabase()' | mongo $host:$port/${CB_DATABASE_NAME} --quiet
  elif [ "$role" == "CM" ]
  then
    echo 'db.dropDatabase()' | mongo $host:$port/${CM_DATABASE_NAME} --quiet
  elif [ "$role" == "CP1" ]
  then
    echo 'db.dropDatabase()' | mongo $host:$port/${CP1_DATABASE_NAME} --quiet
  elif [ "$role" == "CP2" ]
  then
    echo 'db.dropDatabase()' | mongo $host:$port/${CP2_DATABASE_NAME} --quiet
  elif [ "$role" == "CP3" ]
  then
    echo 'db.dropDatabase()' | mongo $host:$port/${CP3_DATABASE_NAME} --quiet
  elif [ "$role" == "CP4" ]
  then
    echo 'db.dropDatabase()' | mongo $host:$port/${CP4_DATABASE_NAME} --quiet
  elif [ "$role" == "CP5" ]
  then
    echo 'db.dropDatabase()' | mongo $host:$port/${CP5_DATABASE_NAME} --quiet
  else
    echo 'db.dropDatabase()' | mongo $db --quiet
  fi
}


# ------------------------------------------------------------------------------
#
# dbDrop - 
#
function dbDrop()
{
  db=$1

  if [ "$CB_DB_DROP" != "No" ]
  then
    if [ "$db" != "" ]
    then
      dbInit $db
    fi
  fi
}



# ------------------------------------------------------------------------------
#
# dbResetAll - 
#
function dbResetAll()
{
  host="${CB_DATABASE_HOST}"
  if [ "$host" == "" ]
  then
    host="localhost"
  fi
  
  port="${CB_DATABASE_PORT}"
  if [ "$port" == "" ]
  then
    port="27017"
  fi
  
  all=$(echo show dbs | mongo $host:$port --quiet | grep ftest | awk '{ print $1 }')
  for db in $all
  do
    dbDrop $db
  done
}



# ------------------------------------------------------------------------------
#
# localBrokerStart
#
function localBrokerStart()
{
  role=$1
  traceLevels=$2
  ipVersion=$3

  POOL_SIZE=${POOL_SIZE:-10}

  shift
  shift
  shift

  extraParams=$*

  IPvOption=""
  
  dbHost="${CB_DATABASE_HOST}"
  if [ "$dbHost" == "" ]
  then
    dbHost="localhost"
  fi
  
  dbPort="${CB_DATABASE_PORT}"
  if [ "$dbPort" == "" ]
  then
    dbPort="27017"
  fi

  dMsg starting broker for role $role

  if [ "$ipVersion" == "IPV4" ]
  then
    IPvOption="-ipv4" 
  elif [ "$ipVersion" == "IPV6" ]
  then
    IPvOption="-ipv6"
  fi

  if [ "$role" == "CB" ]
  then
    port=$CB_PORT
    CB_START_CMD="contextBroker -harakiri -port $CB_PORT  -pidpath $CB_PID_FILE  -dbhost $dbHost:$dbPort -db $CB_DATABASE_NAME -dbPoolSize $POOL_SIZE -t $traceLevels $IPvOption $extraParams"
  elif [ "$role" == "CM" ]
  then
    mkdir -p $CM_LOG_DIR
    port=$CM_PORT
    CB_START_CMD="contextBroker -harakiri -port $CM_PORT  -pidpath $CM_PID_FILE -dbhost $dbHost:$dbport  -db $CM_DATABASE_NAME -dbPoolSize $POOL_SIZE -t $traceLevels $IPvOption -logDir $CM_LOG_DIR -fwdPort $CB_PORT -ngsi9 $extraParams"
  elif [ "$role" == "CP1" ]
  then
    mkdir -p $CP1_LOG_DIR
    port=$CP1_PORT
    CB_START_CMD="contextBroker -harakiri -port $CP1_PORT -pidpath $CP1_PID_FILE -dbhost $dbHost:$dbport -db $CP1_DATABASE_NAME -dbPoolSize $POOL_SIZE -t $traceLevels $IPvOption -logDir $CP1_LOG_DIR $extraParams"
  elif [ "$role" == "CP2" ]
  then
    mkdir -p $CP2_LOG_DIR
    port=$CP2_PORT
    CB_START_CMD="contextBroker -harakiri -port $CP2_PORT -pidpath $CP2_PID_FILE -dbhost $dbHost:$dbport -db $CP2_DATABASE_NAME -dbPoolSize $POOL_SIZE -t $traceLevels $IPvOption -logDir $CP2_LOG_DIR $extraParams"
  elif [ "$role" == "CP3" ]
  then
    mkdir -p $CP3_LOG_DIR
    port=$CP3_PORT
    CB_START_CMD="contextBroker -harakiri -port $CP3_PORT -pidpath $CP3_PID_FILE -dbhost $dbHost:$dbport -db $CP3_DATABASE_NAME -dbPoolSize $POOL_SIZE -t $traceLevels $IPvOption -logDir $CP3_LOG_DIR $extraParams"
  elif [ "$role" == "CP4" ]
  then
    mkdir -p $CP4_LOG_DIR
    port=$CP4_PORT
    CB_START_CMD="contextBroker -harakiri -port $CP4_PORT -pidpath $CP4_PID_FILE -dbhost $dbHost:$dbport -db $CP4_DATABASE_NAME -dbPoolSize $POOL_SIZE -t $traceLevels $IPvOption -logDir $CP4_LOG_DIR $extraParams"
  elif [ "$role" == "CP5" ]
  then
    mkdir -p $CP5_LOG_DIR
    port=$CP5_PORT
    CB_START_CMD="contextBroker -harakiri -port $CP5_PORT -pidpath $CP5_PID_FILE -dbhost $dbHost:$dbport -db $CP5_DATABASE_NAME -dbPoolSize $POOL_SIZE -t $traceLevels $IPvOption -logDir $CP5_LOG_DIR $extraParams"
  fi

  if [ "$VALGRIND" == "" ]; then
    $CB_START_CMD
    # Wait some time so that the contextBroker is able to do its initial steps (reset database, start HTTP server, etc.)
    sleep 1
  else
    valgrind $CB_START_CMD > /tmp/valgrind.out 2>&1 &
    # Waiting for valgrind to start (sleep 10)
    sleep 10s
  fi

  # Test to see whether we have a broker running on $port. If not raise an error
  running_broker=$(ps -fe | grep contextBroker | grep $port | wc -l)
  if [ $running_broker -ne 1 ]; then
    echo "Unable to start contextBroker"
    exit 1
  fi

  ps=$(ps aux | grep contextBroker)
  dMsg $ps
}



# ------------------------------------------------------------------------------
#
# localBrokerStop
#
function localBrokerStop
{
  role=$1

  if [ "$role" == "CB" ]
  then
    port=$CB_PORT
  elif [ "$role" == "CM" ]
  then
    port=$CM_PORT
  elif [ "$role" == "CP1" ]
  then
    port=$CP1_PORT
  elif [ "$role" == "CP2" ]
  then
    port=$CP2_PORT
  elif [ "$role" == "CP3" ]
  then
    port=$CP3_PORT
  elif [ "$role" == "CP4" ]
  then
    port=$CP4_PORT
  elif [ "$role" == "CP5" ]
  then
    port=$CP5_PORT
  fi

  # Test to see if we have a broker running on $port if so kill it!
  running_broker=$(ps -fe | grep contextBroker | grep $port | wc -l)
  if [ $running_broker -ne 0 ]; then
    kill $(ps -fe | grep contextBroker | grep $port | awk '{print $2}') 2> /dev/null
    # Wait some time so the broker can finish properly
    sleep 1
    running_broker=$(ps -fe | grep contextBroker | grep $port | wc -l)
    if [ $running_broker -ne 0 ]; then
      # If the broker refuses to stop politely, kill the process by brute force
      kill -9 $(ps -fe | grep contextBroker | grep $port | awk '{print $2}') 2> /dev/null
      sleep 1
      running_broker=$(ps -fe | grep contextBroker | grep $port | wc -l)
      if [ $running_broker -ne 0 ]; then
        echo "Existing contextBroker is immortal, can not be killed!"
        exit 1
      fi
    fi
  fi
}



# ------------------------------------------------------------------------------
#
# brokerStart
#
function brokerStart()
{
  role=$1
  traceLevels=$2
  ipVersion=$3

  shift
  shift
  shift

  extraParams=$*

  if [ "$role" == "" ]
  then
    echo "No role given as first parameter for brokerStart"
    return
  fi

  if [ "$traceLevels" == "" ]
  then
    traceLevels=0-255
  fi

  localBrokerStop $role
  localBrokerStart $role $traceLevels $ipVersion $extraParams
}



# ------------------------------------------------------------------------------
#
# brokerStop - 
#
function brokerStop
{
  role=$1

  if [ "$role" == "CB" ]
  then
    pidFile=$CB_PID_FILE
    port=$CB_PORT
  elif [ "$role" == "CM" ]
  then
    pidFile=$CM_PID_FILE
    port=$CM_PORT
  elif [ "$role" == "CP1" ]
  then
    pidFile=$CP1_PID_FILE
    port=$CP1_PORT
  elif [ "$role" == "CP2" ]
  then
    pidFile=$CP2_PID_FILE
    port=$CP2_PORT
  elif [ "$role" == "CP3" ]
  then
    pidFile=$CP3_PID_FILE
    port=$CP3_PORT
  elif [ "$role" == "CP4" ]
  then
    pidFile=$CP4_PID_FILE
    port=$CP4_PORT
  elif [ "$role" == "CP5" ]
  then
    pidFile=$CP5_PID_FILE
    port=$CP5_PORT
  fi

  if [ "$VALGRIND" == "" ]; then
    kill $(cat $pidFile 2> /dev/null) 2> /dev/null
    if [ -f /tmp/orion_${port}.pid ]
    then
      rm -f /tmp/orion_${port}.pid 2> /dev/null
    fi
  else
    curl localhost:${port}/exit/harakiri 2> /dev/null >> ${TEST_BASENAME}.valgrind.stop.out
    # Waiting for valgrind to terminate (sleep 10)
    sleep 10
  fi
}



# ------------------------------------------------------------------------------
#
# proxyCoapStart
#
function proxyCoapStart()
{
  extraParams=$*

  proxyCoap $extraParams -cbPort $CB_PORT

  # Test to see whether we have a proxy running. If not raise an error
  running_proxyCoap=$(ps -fe | grep ' proxyCoap' | grep "cbPort $CB_PORT" | wc -l)
  if [ "$running_proxyCoap" == "" ]
  then
    echo "Unable to start proxyCoap"
    exit 1
  fi
}



# ------------------------------------------------------------------------------
#
# proxyCoapStop
#
function proxyCoapStop
{
  port=$COAP_PORT

  # Test to see if we have a proxy running if so kill it!
  running_proxyCoap=$(ps -fe | grep proxyCoap | wc -l)
  if [ $running_proxyCoap -ne 1 ]; then
    kill $(ps -fe | grep proxyCoap | awk '{print $2}') 2> /dev/null
    # Wait some time so the proxy can finish properly
    sleep 1
    running_proxyCoap=$(ps -fe | grep proxyCoap | wc -l)
    if [ $running_proxyCoap -ne 1 ]; then
      # If the proxy refuses to stop politely, kill the process by brute force
      kill -9 $(ps -fe | grep proxyCoap | awk '{print $2}') 2> /dev/null
      sleep 1
      running_proxyCoap=$(ps -fe | grep proxyCoap | wc -l)
      if [ $running_proxyCoap -ne 1 ]; then
        echo "Existing proxyCoap is immortal, can not be killed!"
        exit 1
      fi
    fi
  fi
}


# ------------------------------------------------------------------------------
#
# accumulatorStop - 
#
function accumulatorStop()
{
  port=$1

  # If port is missing, we use the default LISTENER_PORT
  if [ -z "$port" ]
  then
    port=${LISTENER_PORT}
  fi

  pid=$(cat /tmp/accumulator.$port.pid 2> /dev/null)
  if [ "$pid" != "" ]
  then
    kill -15 $pid 2> /dev/null
    sleep .1
    kill -2 $pid 2> /dev/null
    sleep .1
    kill -9 $pid 2> /dev/null
    rm -f /tmp/accumulator.$port.pid
  fi
}


# ------------------------------------------------------------------------------
#
# accumulatorStart - 
#
function accumulatorStart()
{
  bindIp=$1
  port=$2

  # If port is missing, we use the default LISTENER_PORT
  if [ -z "$port" ]
  then
    port=$LISTENER_PORT
  fi

  accumulatorStop $port

  accumulator-server.py $port /notify $bindIp > /tmp/accumulator_${port}_stdout 2> /tmp/accumulator_${port}_stderr &
  echo accumulator running as PID $$

  # Wait until accumulator has started or we have waited a given maximum time
  port_not_ok=1
  typeset -i time
  time=0

  until [ $port_not_ok -eq 0 ]
  do
   if [ "$time" -eq "$MAXIMUM_WAIT" ]
   then
      echo "Unable to start listening application after waiting ${MAXIMUM_WAIT}"
      exit 1
   fi 
   sleep 1

   time=$time+1
   nc -z localhost $port
   port_not_ok=$?
  done
}



# ------------------------------------------------------------------------------
#
# accumulatorDump
#
function accumulatorDump()
{
  valgrindSleep 2

  if [ "$1" == "IPV6" ]
  then
    curl -g [::1]:${LISTENER_PORT}/dump -s -S 2> /dev/null
  else
    curl localhost:${LISTENER_PORT}/dump -s -S 2> /dev/null
  fi
}


# ------------------------------------------------------------------------------
#
# accumulator2Dump
#
function accumulator2Dump()
{
  valgrindSleep 2

  if [ "$1" == "IPV6" ]
  then
    curl -g [::1]:${LISTENER2_PORT}/dump -s -S 2> /dev/null
  else
    curl localhost:${LISTENER2_PORT}/dump -s -S 2> /dev/null
  fi
}

# ------------------------------------------------------------------------------
#
# accumulatorCount
#
function accumulatorCount()
{
  valgrindSleep 2

  if [ "$1" == "IPV6" ]
  then
    curl -g [::1]:${LISTENER_PORT}/number -s -S 2> /dev/null
  else
    curl localhost:${LISTENER_PORT}/number -s -S 2> /dev/null
  fi
}

# ------------------------------------------------------------------------------
#
# accumulator2Count
#
function accumulator2Count()
{
  valgrindSleep 2

  if [ "$1" == "IPV6" ]
  then
    curl -g [::1]:${LISTENER2_PORT}/number -s -S 2> /dev/null
  else
    curl localhost:${LISTENER2_PORT}/number -s -S 2> /dev/null
  fi
}

# ------------------------------------------------------------------------------
#
# valgrindSleep
#
function valgrindSleep()
{
  if [ "$FUNC_TEST_RUNNING_UNDER_VALGRIND" == "true" ]
  then
    sleep $1
  fi
}



# ------------------------------------------------------------------------------
#
# mongoCmd - 
#
# This functions is needed due to some problems with jenkins that seems to avoid
# the usage of 'mongo --quiet ...' directly. Thus, we need to use mongo without
# --quiet, but we need to get rid of some preamble lines about mongo version and
# connection information and a final 'bye' line
#
function mongoCmd()
{

  db=$1
  cmd=$2
  echo $cmd | mongo $db | tail -n 2 | head -n 1
}

# ------------------------------------------------------------------------------
#
# dbInsertEntity -
#
# Insert a crafted entity which and "inflated" attribute. The database is pased
# as first argument and the id of the entity as second. The size of the "inflated"
# attribute is the third argument x 10.
#
function dbInsertEntity()
{
  db=$1
  entId=$2
  size=$3

  # This is a JavaScript code that generates a string variable which length is the
  # one in the argument x 10
  jsCode="s = \"\"; for (var i = 0; i < $size ; i++) { s += \"0123456789\"; }"

  ent="entity = \"$entId\""

  doc='doc = {
    "_id": {
        "id": entity,
        "type": "T"
    },
    "attrNames": [ "A" ],
    "attrs": {
        "A": {
            "type": "TA",
            "value": s,
            "creDate" : 1389376081,
            "modDate" : 1389376081
        },
    },
    "creDate": 1389376081,
    "modDate": 1389376081
  }'

  cmd='db.entities.insert(doc)'

  echo "$jsCode ; $ent ; $doc ; $cmd" | mongo $db
}


# ------------------------------------------------------------------------------
#
# orionCurl
#
# Options:
#   -X            <HTTP method>    (default: according to curl. GET if no payload, POST if with payload)
#   --host        <host>           (default: localhost)
#   --port        <port>           (default: $CB_PORT)
#   --url         <URL>            (default: empty string)
#   --urlParams   <params>         (URI parameters 'in' URL-string)
#   --payload     <payload>        (default: NO PAYLOAD. Possible values: [filename | "${string}"])
#   --in          (input payload)  (default: xml => application/xml, If 'json': application/json)
#   --out         (output payload  (default: xml => application/xml, If 'json': application/json)
#   --json        (in/out JSON)    (if --in/out is used AFTER --json, it overrides) 
#   --tenant      <tenant>         (tenant in HTTP header)
#   --servicePath <path>           (Service Path in HTTP header)
#   --xauthToken  <token>          (X-Auth token value)
#   --origin      <origin>         (Origin in HTTP header)
#   --noPayloadCheck               (don't check the payload)
#   --header      <HTTP header>    (more headers)
#   -H            <HTTP header>    (more headers)
#   --verbose                      (verbose output)
#   -v                             (verbose output)
#   --debug                        (debug mode - output to /tmp/orionFuncTestDebug.log
#
# Any parameters are sent as is to 'curl'
# 
function orionCurl()
{
  payloadCheckFormat='xml'

  dMsg 
  dMsg $(date)
  dMsg orionCurl $*

  _host='localhost'
  _port=$CB_PORT
  _url=''
  _method=''
  _payload=''
  _servicePath=''
  _xtra=''
  _headers=''
  _noPayloadCheck='off'
  _tenant=''
  _origin=''
  _inFormat='--header "Content-Type: application/xml"'
  _outFormat='--header "Accept: application/xml"'
  _in='';
  _out='';
  _json=''
  _urlParams=''
  _xauthToken=''

  #
  # Parsing parameters
  #
  while [ "$#" != 0 ]
  do
    if   [ "$1" == "--host" ]; then            _host=$2; shift;
    elif [ "$1" == "--port" ]; then            _port=$2; shift;
    elif [ "$1" == "--url" ]; then             _url=$2; shift;
    elif [ "$1" == "--urlParams" ]; then       _urlParams=$2; shift;
    elif [ "$1" == "-X" ]; then                _method="-X $2"; shift;
    elif [ "$1" == "--payload" ]; then         _payload=$2; shift;
    elif [ "$1" == "--noPayloadCheck" ]; then  _noPayloadCheck='on';
    elif [ "$1" == "--servicePath" ]; then     _servicePath='--header "Fiware-ServicePath: '${2}'"'; shift;
    elif [ "$1" == "--tenant" ]; then          _tenant='--header "Fiware-Service: '${2}'"'; shift;
    elif [ "$1" == "--origin" ]; then          _origin='--header "Origin: '${2}'"'; shift;
    elif [ "$1" == "-H" ]; then                _headers=${_headers}" --header $2"; shift;
    elif [ "$1" == "--header" ]; then          _headers=${_headers}" --header $2"; shift;
    elif [ "$1" == "--in" ]; then              _in="$2"; shift;
    elif [ "$1" == "--out" ]; then             _out="$2"; shift;
    elif [ "$1" == "--json" ]; then            _in='json'; _out='json'; payloadCheckFormat='json'
    elif [ "$1" == "--xauthToken" ]; then      _xauthToken='--header "X-Auth-Token: '${2}'"'; shift;
    elif [ "$1" == "-v" ]; then                _verbose=on;
    elif [ "$1" == "--verbose" ]; then         _verbose=on;
    elif [ "$1" == "--debug" ]; then           _debug=on;
    elif [ "$1" == "-d" ]; then                _debug=on;
    else                                       _xtra="$_xtra $1";
    fi
    shift
  done

  #
  # Check the parameters
  #

  # 1. Do we have a URL present?
  if [ "$_url" == "" ]
  then
    echo "No URL";
    return 1;
  fi

  # 2. Payload can be either data or a path to a file - if data, a file is created with the data as contents
  _PAYLOAD=''
  if [ "$_payload" != "" ]
  then
    if [ -f "$_payload" ]
    then
      _PAYLOAD="-d @$_payload"
    else
      echo $_payload > /tmp/orionFuncTestPayload
      _PAYLOAD="-d @/tmp/orionFuncTestPayload"
    fi
  fi
  
  # 3. Fix for 'Content-Type' and 'Accept' short names 'xml' and 'json'
  if   [ "$_in"   == "application/xml" ];  then _in='xml';   fi
  if   [ "$_in"   == "application/json" ]; then _in='json';  fi
  if   [ "$_out"  == "application/xml" ];  then _out='xml';  fi
  if   [ "$_out"  == "application/json" ]; then _out='json'; fi

  if   [ "$_in"  == "xml" ];   then _inFormat='--header "Content-Type: application/xml"'
  elif [ "$_in"  == "json" ];  then _inFormat='--header "Content-Type: application/json"'
  elif [ "$_in"  != "" ];      then _inFormat='--header "Content-Type: '${_in}'"'
  fi

  if   [ "$_out" == "xml" ];   then _outFormat='--header "Accept: application/xml"'; payloadCheckFormat='xml'
  elif [ "$_out" == "json" ];  then _outFormat='--header "Accept: application/json"'; payloadCheckFormat='json'
  elif [ "$_out" != "" ];      then _outFormat='--header "Accept: '${_out}'"'; _noPayloadCheck='off'
  fi


  dMsg $_in: $_in
  dMsg _out: $_out
  dMsg _outFormat: $_outFormat
  dMsg _inFormat: $_inFormat
  dMsg payloadCheckFormat: $payloadCheckFormat
  dMsg _noPayloadCheck: $_noPayloadCheck


  #
  # Assemble the command
  #
  command='curl "'$_host':'${_port}${_url}'"'

  if [ "$_urlParams"   != "" ]; then  command=${command}'?'${_urlParams};   fi
  if [ "$_PAYLOAD"     != "" ]; then  command=${command}' '${_PAYLOAD};     fi
  if [ "$_method"      != "" ]; then  command=${command}' '${_method};      fi
  if [ "$_tenant"      != "" ]; then  command=${command}' '${_tenant};      fi
  if [ "$_servicePath" != "" ]; then  command=${command}' '${_servicePath}; fi 
  if [ "$_inFormat"    != "" ]; then  command=${command}' '${_inFormat};    fi
  if [ "$_outFormat"   != "" ]; then  command=${command}' '${_outFormat};   fi
  if [ "$_origin"      != "" ]; then  command=${command}' '${_origin};      fi
  if [ "$_xauthToken"  != "" ]; then  command=${command}' '${_xauthToken};  fi
  if [ "$_headers"     != "" ]; then  command=${command}' '${_headers};     fi
  if [ "$_xtra"        != "" ]; then  command=${command}' '${_xtra};        fi

  command=${command}' --header "Expect:"'
  command=${command}' -s -S --dump-header /tmp/httpHeaders.out'
  dMsg command: $command


  #
  # Execute the command
  #
  dMsg Executing the curl-command
  _response=$(eval $command 2> /dev/null)


  #
  # Remove "Connection: Keep-Alive" and "Connection: close" headers
  #
  sed '/Connection: Keep-Alive/d' /tmp/httpHeaders.out  > /tmp/httpHeaders2.out
  sed '/Connection: close/d'      /tmp/httpHeaders2.out > /tmp/httpHeaders.out
  sed '/Connection: Close/d'      /tmp/httpHeaders.out  
  

  #
  # Print and beautify response body, if any - and if option --noPayloadCheck hasn't been set
  #
  if [ "$_noPayloadCheck" == "on" ]
  then
    echo $_response
  else
    if [ "$_response" != "" ]
    then
      dMsg buffer to $payloadCheckFormat beautify: $_response

      if [ "$payloadCheckFormat" == xml ] || [ "$payloadCheckFormat" == "" ]
      then
        vMsg Running xmllint tool for $_response
        echo $_response | xmllint --format -
      elif [ "$payloadCheckFormat" == json ]
      then
        vMsg Running python tool for $_response
        echo $_response | python -mjson.tool
      else
        vMsg Running xmllint tool for $_response
        echo $_response | xmllint --format -
      fi
    fi
  fi
}


# ------------------------------------------------------------------------------
#
# coapCurl
#
# Options:
#   -X            <HTTP method>    (default: according to curl. GET if no payload, POST if with payload)
#   --host        <host>           (default: localhost)
#   --port        <port>           (default: $COAP_PORT)
#   --url         <URL>            (default: empty string)
#   --payload     <payload>        (default: NO PAYLOAD. Possible values: [filename | "${string}"])
#   --in          (input payload)  (default: xml => application/xml, If 'json': application/json)
#   --out         (output payload  (default: xml => application/xml, If 'json': application/json)
#   --json        (in/out JSON)    (if --in/out is used AFTER --json, it overrides)
#   --tenant      <tenant>         (tenant in HTTP header)
#   --servicePath <path>           (Service Path in HTTP header)
#   --noPayloadCheck               (skip paylosd check filter)
#
# Any parameters are sent as is to 'curl'
#
function coapCurl()
{
  #
  # Default values
  #
  _method=""
  _host="0.0.0.0"
  _port=$COAP_PORT
  _url=""
  _payload=""
  _inFormat=""
  _outFormat=""
  _json=""
  _tenant=""
  _servicePath=""
  _xtra=''
  _noPayloadCheck='off'

  while [ "$#" != 0 ]
  do
    if   [ "$1" == "-X" ]; then                _method="$2"; shift;
    elif [ "$1" == "--host" ]; then            _host="$2"; shift;
    elif [ "$1" == "--port" ]; then            _port="$2"; shift;
    elif [ "$1" == "--url" ]; then             _url="$2"; shift;
    elif [ "$1" == "--payload" ]; then         _payload="$2"; shift;
    elif [ "$1" == "--in" ]; then              _inFormat="$2"; shift;
    elif [ "$1" == "--out" ]; then             _outFormat="$2"; shift;
    elif [ "$1" == "--json" ]; then            _inFormat=application/json; _outFormat=application/json;
    elif [ "$1" == "--tenant" ]; then          _tenant="$2"; shift;
    elif [ "$1" == "--servicePath" ]; then     _servicePath="$2"; shift;
    elif [ "$1" == "--noPayloadCheck" ]; then  _noPayloadCheck=on;
    else                                       _xtra="$_xtra $1"; shift;
    fi

    shift
  done

  #
  # Sanity check of parameters
  #
  if [ "$_url" == "" ]
  then
    echo "No URL";
    return 1;
  fi


  #
  # Fix for 'Content-Type' and 'Accept' short names 'xml' and 'json'
  #
  if [ "$_inFormat" == "xml" ];   then _inFormat=application/xml;   fi;
  if [ "$_outFormat" == "xml" ];  then _outFormat=application/xml;  fi;
  if [ "$_inFormat" == "json" ];  then _inFormat=application/json;  fi;
  if [ "$_outFormat" == "json" ]; then _outFormat=application/json; fi;



  #
  # Cleanup 'compound' variables, so that we don't inherit values from previous calls
  #
  _METHOD=''
  _URL=''
  _ACCEPT=''
  _CONTENTFORMAT=''

  if [ "$_inFormat" != "" ];  then  _CONTENTFORMAT="-t $_inFormat";  fi
  if [ "$_outFormat" != "" ]; then  _ACCEPT="-A $_outFormat";        fi
  if [ "$_method" != "" ];    then  _METHOD=' -m '$_method;          fi

  _URL="coap://$_host:$_port$_url"

  #   usage: coap-client [-A type...] [-t type] [-b [num,]size] [-B seconds] [-e text]
  #                   [-g group] [-m method] [-N] [-o file] [-P addr[:port]] [-p port]
  #                   [-s duration] [-O num,text] [-T string] [-v num] URI
  #
  #           URI can be an absolute or relative coap URI,
  #           -A type...      accepted media types as comma-separated list of
  #                           symbolic or numeric values
  #           -t type         content type for given resource for PUT/POST
  #           -b [num,]size   block size to be used in GET/PUT/POST requests
  #                           (value must be a multiple of 16 not larger than 1024)
  #                           If num is present, the request chain will start at
  #                           block num
  #           -B seconds      break operation after waiting given seconds
  #                           (default is 90)
  #           -e text         include text as payload (use percent-encoding for
  #                           non-ASCII characters)
  #           -f file         file to send with PUT/POST (use '-' for STDIN)
  #           -g group        join the given multicast group
  #           -m method       request method (get|put|post|delete), default is 'get'
  #           -N              send NON-confirmable message
  #           -o file         output received data to this file (use '-' for STDOUT)
  #           -p port         listen on specified port
  #           -s duration     subscribe for given duration [s]
  #           -v num          verbosity level (default: 3)
  #           -O num,text     add option num with contents text to request
  #           -P addr[:port]  use proxy (automatically adds Proxy-Uri option to
  #                           request)
  #           -T token        include specified token
  #
  #   examples:
  #           coap-client -m get coap://[::1]/
  #           coap-client -m get coap://[::1]/.well-known/core
  #           coap-client -m get -T cafe coap://[::1]/time
  #           echo 1000 | coap-client -m put -T cafe coap://[::1]/time -f -


  _BUILTINS='-B 1 -b 1024'


#   echo '====================================================================================='
  if [ "$_payload" != "" ]
  then
#     echo "echo "$_payload" | ./coap-client -f - $_BUILTINS $_METHOD $_ACCEPT $_CONTENTFORMAT $_URL"
    _response=$(echo "$_payload" | coap-client -f - $_BUILTINS $_METHOD $_ACCEPT $_CONTENTFORMAT $_URL)
  else
#     echo "./coap-client $_BUILTINS $_METHOD $_ACCEPT $_CONTENTFORMAT $_URL"
    _response=$(coap-client $_BUILTINS $_METHOD $_ACCEPT $_CONTENTFORMAT $_URL)
  fi
#   echo '====================================================================================='


  # Get headers
  _responseHeaders=$(echo "$_response" | head -n 1)

  # Strip headers and garbage bytes from response
  _response=$(echo "$_response" | tail -n +2 | head -c-3)


  echo $_responseHeaders
  echo

  #
  # Print and beautify response body (IF ANY)
  #
  if [ "$_noPayloadCheck" == "on" ]
  then
    echo $_response
  else
    if [ "$_response" != "" ]
    then
      if [ "$_outFormat" == application/xml ] || [ "$_outFormat" == "" ]
      then
        echo $_response | xmllint --format -
      elif [ "$_outFormat" == application/json ]
      then
        vMsg "JSON check for:" $_response
        echo $_response | python -mjson.tool
      else
        echo $_response | xmllint --format -
      fi
    fi
  fi
}


export -f dbInit
export -f dbDrop
export -f dbResetAll
export -f brokerStart
export -f localBrokerStop
export -f localBrokerStart
export -f brokerStop
export -f localBrokerStop
export -f proxyCoapStart
export -f proxyCoapStop
export -f accumulatorStart
export -f accumulatorStop
export -f accumulatorDump
export -f accumulator2Dump
export -f accumulatorCount
export -f accumulator2Count
export -f orionCurl
export -f dbInsertEntity
export -f mongoCmd
export -f coapCurl
export -f vMsg
export -f dMsg
export -f valgrindSleep