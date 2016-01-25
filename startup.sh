#!/usr/bin/env sh
# File modified from original at https://github.com/sheeprine/docker-netdisco

export PSQL_OPTIONS="-U $NETDISCO_DB_USER -h db"
export PGPASSWORD=$NETDISCO_DB_PASS

provision_netdisco_db() {
    psql $PSQL_OPTIONS -c "CREATE ROLE netdisco WITH LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE password '$NETDISCO_DB_PASS'"
    psql $PSQL_OPTIONS -c "CREATE DATABASE netdisco OWNER netdisco"
}

check_postgres() {
    if [ -z `psql $PSQL_OPTIONS -tAc "SELECT 1 FROM pg_roles WHERE rolname='netdisco'"` ]; then
        provision_netdisco_db
    fi
}

set_environment() {
    ENV_FILE="$NETDISCO_HOME/environments/deployment.yml"
    mkdir $NETDISCO_HOME/environments
    cp $NETDISCO_HOME/perl5/lib/perl5/auto/share/dist/App-Netdisco/environments/deployment.yml $ENV_FILE
    chmod 600 $ENV_FILE
    sed -i "s/user: 'changeme'/user: '$NETDISCO_DB_USER'/" $ENV_FILE
    sed -i "s/pass: 'changeme'/pass: '$NETDISCO_DB_PASS'/" $ENV_FILE
    sed -i "s/#*host: 'localhost'/host: 'db;port=5432'/" $ENV_FILE
    sed -i "s/#*domain_suffix: '.example.com'/domain_suffix: '$NETDISCO_DOMAIN'/" $ENV_FILE

    sed -i "s/community: 'public'/community: '$NETDISCO_RO_COMMUNITY'/" $ENV_FILE

    if [ -n $NETDISCO_WR_COMMUNITY ]; then
        sed -i "/snmp_auth:/a\  - tag: 'default_v2_for_write'" $ENV_FILE
        sed -i "/^  - tag: 'default_v2_for_write/a\    write: true" $ENV_FILE
        sed -i "/^  - tag: 'default_v2_for_write/a\    read: false" $ENV_FILE
        sed -i "/^  - tag: 'default_v2_for_write/a\    community: '$NETDISCO_WR_COMMUNITY'" $ENV_FILE
    fi

    sed -i "/#schedule:/, /when: '20 23 \* \* \*'/ s/#//" $ENV_FILE
}

check_environment() {
    # check if Environment File Exists, if not re-crate
    if [ ! -d $ENV_FILE ]; then
        set_environment
    fi
}

check_postgres
check_environment
# Provide Answers to Configuration Questions of Netdisco
sed -i "s/new('netdisco')/new('netdisco', \\*STDIN, \\*STDOUT)/" $NETDISCO_HOME/perl5/bin/netdisco-deploy
$NETDISCO_HOME/perl5/bin/netdisco-deploy /tmp/oui.txt << ANSWERS
y
y
y
y
ANSWERS
netdisco-web start
netdisco-daemon start
tail -f $NETDISCO_HOME/logs/netdisco-*.log
