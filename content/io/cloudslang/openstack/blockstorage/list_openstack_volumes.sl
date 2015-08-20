#   (c) Copyright 2014 Hewlett-Packard Development Company, L.P.
#   All rights reserved. This program and the accompanying materials
#   are made available under the terms of the Apache License v2.0 which accompany this distribution.
#
#   The Apache License is available at
#   http://www.apache.org/licenses/LICENSE-2.0
#
####################################################
# Retrieves the list of volumes from an OpenStack machine.
#
# Inputs:
#   - host - OpenStack machine host
#   - identity_port - optional - port used for OpenStack authentication - Default: 5000
#   - blockstorage_port - optional - port used for OpenStack computations - Default: 8776
#   - username - OpenStack username
#   - password - OpenStack password
#   - tenant_name - name of the project on OpenStack
#   - proxy_host - optional - proxy server used to access the web site - Default: none
#   - proxy_port - optional - proxy server port - Default: none
# Outputs:
#   - server_list - list of server names
#   - return_result - response of the last operation executed
#   - error_message - error message of the operation that failed
# Results:
#   - SUCCESS
#   - FAILURE
####################################################

namespace: io.cloudslang.openstack.blockstorage

imports:
 openstack_content: io.cloudslang.openstack
 openstack_blockstorage: io.cloudslang.openstack.blockstorage
 openstack_utils: io.cloudslang.openstack.utils

flow:
  name: list_openstack_volumes
  inputs:
    - host
    - identity_port:
        default: "'5000'"
    - blockstorage_port:
        default: "'8776'"
    - username
    - password
    - tenant_name
    - proxy_host:
        required: false
    - proxy_port:
        required: false
  workflow:
    - authentication:
        do:
          openstack_content.get_authentication_flow:
            - host
            - identity_port
            - username
            - password
            - tenant_name
            - proxy_host:
                required: false
            - proxy_port:
                required: false
        publish:
          - token
          - tenant
          - return_result
          - error_message

    - get_openstack_volumes:
        do:
          openstack_blockstorage.get_openstack_volumes:
            - host
            - blockstorage_port
            - token
            - tenant
            - proxy_host:
                required: false
            - proxy_port:
                required: false
        publish:
          - response_body: return_result
          - return_result: return_result
          - error_message

    - extract_servers:
        do:
          openstack_utils.extract_object_list_from_json_response:
            - response_body
            - object_name: "'volumes'"
        publish:
          - object_list
          - error_message

  outputs:
    - volume_list: object_list
    - return_result
    - error_message