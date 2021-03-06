/*
Script creado por Daniel Romero Sánchez cómo ejemplo de apagado de una máquina virtual en 
VMware utilizando la API REST de vSphere, para elibro VMware por vExperts.
*/

import requests
from requests.auth import HTTPBasicAuth

url = 'https://vcenter.vmwareporvexperts.org'

apiPath = '/rest/com/vmware/cis/session';


auth ={
  'username' :'administrator@vmwareporvexperts.org',
  'password' : 'TU_PASSWORD'
}


headers = { 'Accept': 'application/json',
	   'Content-Type': 'application/json',
	   'vmware-use-header-authn' : 'vmwareporvexperts'}

authentication = HTTPBasicAuth(auth['username'], auth['password'])

response = requests.post(url + apiPath, auth = authentication, verify = False, headers = headers)

print (response)
token = response.json()['value']

print (token)


headers = { 'Accept': 'application/json',
	   'Content-Type': 'application/json',
	   'vmware-api-session-id' : token
}

apiPath = '/rest/vcenter/vm'
response = requests.get(url + apiPath, verify = False, headers = headers)
data = response.json()

for vm in data['value']:
	if vm['name'] == 'vm01':
		vmid = vm['vm']
		break


apiPath = '/rest/vcenter/vm/' + vmid + '/power/stop'

response = requests.post(url + apiPath, verify = False, headers = headers)

print (response.status_code)
