/*
Script creado por Daniel Romero Sánchez cómo ejemplo de apagado de una máquina virtual en 
VMware utilizando la API REST de vSphere, para elibro VMware por vExperts.
*/
var unirest = require('unirest')

var settings = {
    username :'administrator@vmwareporvexperts.org',
    password : 'TU_PASSWORD',
    host: 'https://vcenter.vmwareporvexperts.org',
    ssl: false
}

async function getToken(){
    var apiPath = '/rest/com/vmware/cis/session';
    var uri = settings.host + apiPath
    return new Promise(function(resolve, reject) {
      unirest.post(uri)
          .strictSSL(settings.ssl)
          .auth(settings.username, settings.password)
          .headers({'Accept': 'application/json', 'Content-Type': 'application/json', 'vmware-use-header-authn' : 'vmwareporvexperts'})
          .end(function (response) {
            resolve(response.body);
          });
      });
}

async function stopVM(){
    var token = await getToken()
    console.log(token.value)
    var uri = settings.host + '/rest/vcenter/vm'
    var header = { 'Accept': 'application/json',
                    'Content-Type': 'application/json',
                    'vmware-api-session-id' : token.value
    }

    unirest.get(uri)
          .strictSSL(settings.ssl)
          .headers(header)
          .end(function (response) {
              response.body.value.forEach(function(element) {
                  if (element.name == 'vm01'){
                    var vmid = element.vm
                    console.log(vmid)
                    uri = settings.host + '/rest/vcenter/vm/'+vmid+'/power/stop'
                    unirest.post(uri)
                           .strictSSL(settings.ssl)
                           .headers(header)
                           .end(function (response) {
                              console.log(response.code)
                     });

                  }
              });

     });
}

stopVM()
