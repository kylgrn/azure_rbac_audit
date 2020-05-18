# Azure RBAC Permissions Export
##Overview
The purpose of this script is to iterate through Azure susbcriptions and export the permissions to an Excel file for review. The script will highlight any permissions explicitly applied (i.e. user account and not a group), as well as any owner permissions. 

###Requirements
1) Must has the Azure Powershell module downloaded and installed: https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-3.8.0

2) Requires the "ImportExcel" module, must be installed prior to running the script: https://github.com/dfinke/ImportExcel

3) Must be logged in using the Login-AzAccount command
