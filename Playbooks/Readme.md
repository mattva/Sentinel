AddIPToWAFDenyCustomRule
  
  Parameters:
  * Subscription ID where the Frontdoor WAF policy is defined
  * Resource Group where the Frontdoor WAF policy is defined
  * Name of the FrontDoor WAF Policy
  
  If exists a custom rule named "DefaultDeny" in the configured Frontdoor WAF Policy, then adds the IP to the match conditions. If the policy doesn't exists, the playbook adds it with priority 999
  
  
  1. In Sentinel, create a new playbook with Sentinel Alert trigger
  2. In the Designer, create a new "Invoke an HTTP request" action to create the connector to https://management.azure.com
  3. copy and paste the json text in the code view editor, being careful to not overwrite the connectors part
  4. configure parameters: Subscription ID, Resource GRoup and WAF Policy Name
