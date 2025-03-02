use std log

def init-env [] { {names: {}} }

$env.KUBE_CACHE = (init-env)

def makectx [] {
  {
    namespace: "default"
    ctx: (kubectl config current-context | str trim)
    current: {name: null, type_alias: null}
    type_aliases: (kubectl api-resources | from ssv -a | each {|x| let n = ($x.shortnames | split  row ',' | get 0 | str trim ); if ($n | is-empty) { $x.name } else { $n } })
  }
}

$env.K = (makectx)

def type-aliases [] { $env.K.type_aliases }

def --env get-kube-names [
  alias: string
] {
  let alias_value = $env.KUBE_CACHE.names | get -i $alias

  if $alias_value == null {
    let new_names = (invoke-kubectl get $alias -o name | lines | each { |line| ($line | split row "/" | get 1) })
    let cache = $env.KUBE_CACHE.names | upsert $"($alias)" $new_names
    $env.KUBE_CACHE = {names: $cache }
    return $new_names
  }
  
  return $alias_value
}

def --env typed-kube-names [context: string] {
    let type = $context | split words | last
    get-kube-names $type
}


def rsname [] {
  $"($env.K.current.type_alias)/($env.K.current.name)"
}

def --env reload [
  --hard (-h)
] {
  let names_record = $env.KUBE_CACHE.names
  let namespaces = $names_record | get -i "ns"
  let namespace = $env.K.namespace

  $env.K = (makectx)
  $env.KUBE_CACHE = {names: {}}

  if not $hard {
    if $namespaces != null {
      $env.KUBE_CACHE.names = ($env.KUBE_CACHE.names | upsert "ns" $namespaces)
    }
    $env.K = ($env.K | upsert "namespace" $namespace)
  }
}

def --wrapped invoke-kubectl [...args] {
  let namespace = $env.K.namespace
  let kargs = if $namespace != null { ["-n", $namespace] } else { [] }
  let full_args = ($kargs | append $args) 
  log debug ([kubectl] | append $full_args | str join " ")
  kubectl ...$full_args
}

def get-contexts [] { kubectl config get-contexts -o name | lines }

def --env select-kube-context [
  name?: string@get-contexts
] {
  if $name == null { return get-contexts }
  
  let contexts = (get-contexts)
  if $name not-in $contexts {
    error make {msg: $"Context '($name)' not found"}
  }
  
  reload --hard
  $env.K = ($env.K | upsert "ctx" $name)
  kubectl config use-context $name
}


def --env get-namespaces [] = { get-kube-names "ns" }

def --env select-kube-namespace [
  name?: string@get-namespaces
] {
  if $name == null {
    get-namespaces
    return
  }
  
  let namespaces = (get-namespaces)
  if $name not-in $namespaces {
    error make {msg: $"Namespace '($name)' not found"}
  }
  
  reload
  $env.K = ($env.K | upsert "namespace" $name)
}

def --env select-kube-resource [
  type: string@type-aliases, 
  name?: string@typed-kube-names
] {

  if $name == null {
    reload
    invoke-kubectl get po
    return
  }
  typed-kube-names $type # this is needed for caching only - calling it in completion doesn't seem to export env changes
  $env.K = ($env.K | upsert "current" {name: $name, type_alias: $type})
}

def get-kube-yaml [] {
  invoke-kubectl get (rsname) --output yaml
}

def get-kube-jsonpath [
  jsonpath: string
] {
  invoke-kubectl get (rsname) -o $"jsonpath={($jsonpath)}"
}

def get-kube-describe-resource [] {
  invoke-kubectl describe (rsname)
}

def get-kube-logs [
  --follow (-f),
  --tail (-t): int = 0,
  --container (-c): string
] {
  let tail_arg = if $tail > 0 { $"--tail=($tail)" } else { "" }
  let follow_arg = if $follow { "--follow" } else { "" }
  let container_arg = if $container != null { $"--container=($container)" } else { "" }
   
  let args = [$tail_arg, $follow_arg, $container_arg] | where { is-not-empty }
  invoke-kubectl logs (rsname) ...$args
}

def delete-kube-resource [] {
  invoke-kubectl delete (rsname)
  reload
}

def restart-kube-resource [] {
  invoke-kubectl rollout restart (rsname)
  wait-for-kube-resource available
  invoke-kubectl get po --watch
  reload
}

def wait-for-kube-resource [
  condition: string = "available"
] {
  invoke-kubectl wait (rsname) $"--for=condition=($condition)"
}

def follow-kube-logs [
  container?: string
] {
  get-kube-logs --tail 1 --follow --container $container
}

def invoke-kube-pod-cmd [
  cmd?: string = "sh",
  container?: string
] {
  let container_arg = if $container != null { $"--container=($container)" } else { "" }
  invoke-kubectl exec -it (rsname) $container_arg -- $cmd
}

def invoke-kube-port-forward [
  remote_port?: int,
  local_port?: int = 0,
  --browse (-b)
] {
  if $remote_port == null {
    let target = (rsname)
    let port_jsonpath = if ($target | str starts-with "svc/") {
      "jsonpath='{.spec.ports[*].port}'"
    } else if ($target | str starts-with "pod/") {
      "jsonpath='{.spec.containers[*].ports[*].containerPort}'"
    } else {
      ""
    }
    
    if $port_jsonpath != "" {
      invoke-kubectl get $target "-o" $port_jsonpath | split row " "
    }
    return
  }
  
  let final_local_port = if $local_port == 0 {
    if $remote_port <= 1024 { $remote_port + 8000 } else { $remote_port }
  } else {
    $local_port
  }
  
  if $browse {
    x-www-browser $"http://127.0.0.1:($final_local_port)"
  }
  
  invoke-kubectl port-forward (rsname) $"($final_local_port):($remote_port)"
}

def create_prompt [] {
  
  let ctx = $env.K.ctx
  let namespace = $env.K.namespace
  let current = $env.K.current
  
  let ctx_part = $"($ctx) /"
  
  if $namespace == null {
    $"λ ($ctx_part)"
  } else {
    let ns_part = $" ($namespace) /"
    
    if $current == null or $current.name == null {
      $"λ ($ctx_part)($ns_part)"
    } else {
      let type_alias = $current.type_alias
      let name = $current.name
      let rs_type_part = $" ($type_alias) /"
      let rs_name_part = $" ($name) /"
      $"λ ($ctx_part)($ns_part)($rs_type_part)($rs_name_part)"
    }
  }
}

$env.PROMPT_COMMAND_RIGHT = { create_prompt }

reload --hard

alias k = invoke-kubectl
alias kx = select-kube-context
alias ns = select-kube-namespace
alias rs = select-kube-resource
alias yaml = get-kube-yaml
alias jp = get-kube-jsonpath
alias desc = get-kube-describe-resource
alias delete = delete-kube-resource
alias restart = restart-kube-resource
alias w8 = wait-for-kube-resource
alias pf = invoke-kube-port-forward
alias logs = get-kube-logs
alias flogs = follow-kube-logs
alias x = invoke-kube-pod-cmd
