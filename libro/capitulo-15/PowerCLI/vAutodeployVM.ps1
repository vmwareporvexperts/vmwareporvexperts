<# 
.DESCRIPTION
   vAutodeployVM.ps1 es un script que nos ayuda a automatizar desplieques de VMs

.NOTES 
   File Name  : vAutodeployVM.ps1 
   Author     : Miquel Mariano - @miquelMariano
   Version    : 1

.REQUISITES
   PowerCLI 5.5 o superior
   Tener un template o VM que nos sirva de base al despliegue
   Tener una plantilla de Custom Specifications Manager (https://www.ncora.com/blog/2016/11/01/customizacion-de-templates-en-vsphere/)
   
.USAGE
  Ejecutar directamente vAutodeploy.ps1
 
.CHANGELOG
   v1	02/02/2019	Creación del script

    
#>

#--------------VARIABLES GLOBALES----------------------
$Quantity = 1
$BaseVMname = "VM-DEMO-"
$PrimerVMxx = 10 #Valor autoincremental del nº de VM. VM-DEMOxx
$NameTemplate_or_VM = "miquel-template-W2012R2-Std-ES" #La base para la nueva VM puede ser una plantilla o un clon de otra VM
$Is_template = 0 # Valor 1 si se va a desplegar desde una plantilla o 0 si es un clon de otra VM
$CustomSpec = "miquel-windows-domain-ncoraformacion-dhcp"
$Cluster = "Cluster-EVC"
$Datastore = "G350_FORM_NLSAS_LUN000"
$VLAN = "VLAN6-Formacion"
$PrimeraIP = 110  #Valor del último octeto de la IP. 10.0.0.xx Se irá autoincrementando en caso que $Quantity sea mayor a 1
$MemGB = 4
$NumCPU = 2

#--------------VARIABLES CUSTOM SPECIFICATIONS (los parametros deben ser validos para la VLAN que especifiquemos en la variable $VLAN)---------
$net = "10.0.0."
$mask = "255.255.255.0"
$gw = "10.0.0.1"

$pdns = "8.8.8.8"
$sdns = "4.4.4.4"



#----------BUCLE PARA DESPLEGAR N MAQUINAS-------------
for ($n=1;$n -le $Quantity; $n++) {
$vmname = $BaseVMname+$PrimerVMxx
write-host Desplegando $vmname de $quantity servers -foregroundcolor yellow
$ip = $net+$PrimeraIP
#asignamos una ip estatica a la customización
Get-OSCustomizationSpec $CustomSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $ip -SubnetMask $mask -DefaultGateway $gw -DNS $pdns,$sdns

if ($Is_template -eq 1){
	New-VM -Name $vmname -OSCustomizationSpec $CustomSpec -ResourcePool $Cluster -Template $NameTemplate_or_VM -Datastore $Datastore						
}

if ($Is_template -eq 0){
	New-VM -Name $vmname -OSCustomizationSpec $CustomSpec -ResourcePool $Cluster -VM $NameTemplate_or_VM -Datastore $Datastore						
}

Get-VM -Name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $VLAN -Confirm:$false
Get-VM -Name $vmname | Set-VM -MemoryGB $MemGB -NumCPU $NumCPU -Confirm:$false
Start-VM -VM $vmname
$PrimeraIP++
$PrimerVMxx++
}

#configuramos la customización para que la IP sea asignada mediante asistente
Get-OSCustomizationSpec $CustomSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode PromptUser -SubnetMask $mask -DefaultGateway $gw -DNS $pdns,$sdns


