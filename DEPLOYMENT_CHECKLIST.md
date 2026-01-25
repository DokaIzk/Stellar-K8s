# Dynamic Peer Discovery - Deployment Checklist

## Pre-Deployment

- [ ] Review the implementation summary: `IMPLEMENTATION_SUMMARY.md`
- [ ] Read the quick start guide: `docs/QUICK_START_PEER_DISCOVERY.md`
- [ ] Review the full documentation: `docs/peer-discovery.md`
- [ ] Understand the architecture: `PEER_DISCOVERY_IMPLEMENTATION.md`
- [ ] Verify Rust code compiles: `cargo build --release`
- [ ] Run existing tests: `cargo test`

## RBAC Configuration

- [ ] Verify operator has permission to list StellarNode resources (all namespaces)
- [ ] Verify operator has permission to get Service resources (all namespaces)
- [ ] Verify operator has permission to get Pod resources (all namespaces)
- [ ] Verify operator has permission to create/patch ConfigMap in `stellar-system` namespace
- [ ] Check existing ClusterRole for these permissions
- [ ] Update ClusterRole if needed

**Example RBAC Check**:
```bash
kubectl get clusterrole stellar-operator -o yaml | grep -A 20 "configmaps"
```

## Namespace Setup

- [ ] Ensure `stellar-system` namespace exists
- [ ] Create if missing: `kubectl create namespace stellar-system`
- [ ] Verify namespace is accessible to operator

## Operator Deployment

- [ ] Build new operator image with peer discovery code
- [ ] Push image to registry
- [ ] Update operator deployment with new image
- [ ] Verify operator pod starts successfully
- [ ] Check operator logs for startup messages

**Verify Startup**:
```bash
kubectl logs deployment/stellar-operator -n stellar-system | grep "peer discovery"
```

Expected output:
```
INFO stellar_k8s::controller::peer_discovery: Starting peer discovery watcher
```

## Initial Testing

### Test 1: Single Validator

- [ ] Deploy a single validator: `kubectl apply -f examples/peer-discovery-example.yaml`
- [ ] Wait for validator to be ready (2-5 minutes)
- [ ] Check if ConfigMap is created: `kubectl get configmap stellar-peers -n stellar-system`
- [ ] Verify peer count is 1: `kubectl get configmap stellar-peers -n stellar-system -o jsonpath='{.data.peer_count}'`

### Test 2: Multiple Validators

- [ ] Deploy second validator
- [ ] Wait for it to be ready
- [ ] Verify peer count increased to 2
- [ ] Check peers.json contains both validators

**Verify Peers**:
```bash
kubectl get configmap stellar-peers -n stellar-system -o jsonpath='{.data.peers\.json}' | jq
```

### Test 3: Peer Removal

- [ ] Delete one validator: `kubectl delete stellarnode validator-1 -n stellar-nodes`
- [ ] Wait for deletion (1-2 minutes)
- [ ] Verify peer count decreased
- [ ] Check peers.json no longer contains deleted validator

### Test 4: Config Reload

- [ ] Check operator logs for config-reload messages
- [ ] Verify config-reload was triggered for healthy validators

**Check Logs**:
```bash
kubectl logs deployment/stellar-operator -n stellar-system | grep "config-reload"
```

## Monitoring Setup

- [ ] Set up monitoring for peer count
- [ ] Create alerts for peer count changes
- [ ] Monitor operator logs for errors
- [ ] Set up dashboard to visualize peer discovery

**Monitor Peer Count**:
```bash
watch -n 5 'kubectl get configmap stellar-peers -n stellar-system -o jsonpath="{.data.peer_count}"'
```

## Production Deployment

### Pre-Production

- [ ] Test with production-like configuration
- [ ] Test with multiple namespaces
- [ ] Test with high validator count (50+)
- [ ] Test failure scenarios (pod crashes, network issues)
- [ ] Verify performance impact on operator

### Production

- [ ] Deploy to production cluster
- [ ] Monitor for 24 hours
- [ ] Verify all validators are discovered
- [ ] Verify config reload is working
- [ ] Check operator resource usage
- [ ] Verify no errors in logs

### Post-Production

- [ ] Document any custom configuration
- [ ] Update runbooks with peer discovery procedures
- [ ] Train team on monitoring and troubleshooting
- [ ] Set up on-call alerts

## Troubleshooting Checklist

### Peers Not Discovered

- [ ] Check if validators are running: `kubectl get stellarnodes -A`
- [ ] Check if services have IPs: `kubectl get svc -A -l app.kubernetes.io/component=stellar-node`
- [ ] Check operator logs: `kubectl logs deployment/stellar-operator -n stellar-system | grep "peer discovery"`
- [ ] Verify RBAC permissions
- [ ] Check if ConfigMap exists: `kubectl get configmap stellar-peers -n stellar-system`

### Config Reload Not Triggering

- [ ] Check validator health: `kubectl get stellarnodes -A -o wide`
- [ ] Check pod status: `kubectl get pods -A -l app.kubernetes.io/component=stellar-node`
- [ ] Test HTTP endpoint: `kubectl exec <pod> -- curl http://localhost:11626/http-command?admin=true&command=info`
- [ ] Check operator logs for config-reload attempts

### ConfigMap Not Updating

- [ ] Verify ConfigMap exists: `kubectl get configmap stellar-peers -n stellar-system`
- [ ] Check operator RBAC: `kubectl get clusterrole stellar-operator -o yaml`
- [ ] Check operator logs for errors
- [ ] Verify stellar-system namespace exists

## Rollback Plan

If issues occur:

1. **Stop Peer Discovery** (temporary)
   ```bash
   # Scale down operator (will stop peer discovery)
   kubectl scale deployment stellar-operator -n stellar-system --replicas=0
   ```

2. **Investigate**
   ```bash
   # Check logs
   kubectl logs deployment/stellar-operator -n stellar-system
   
   # Check ConfigMap
   kubectl get configmap stellar-peers -n stellar-system -o yaml
   ```

3. **Fix**
   - Update operator code if needed
   - Rebuild and push image
   - Update deployment

4. **Restart**
   ```bash
   # Scale up operator
   kubectl scale deployment stellar-operator -n stellar-system --replicas=1
   ```

## Performance Validation

- [ ] Monitor operator CPU usage (should be minimal)
- [ ] Monitor operator memory usage (should be stable)
- [ ] Monitor ConfigMap update frequency (should be infrequent)
- [ ] Monitor config-reload success rate (should be >95%)
- [ ] Verify no impact on validator performance

**Check Resource Usage**:
```bash
kubectl top pod -n stellar-system -l app=stellar-operator
```

## Documentation Updates

- [ ] Update runbooks with peer discovery procedures
- [ ] Document custom configuration (if any)
- [ ] Add peer discovery to operator documentation
- [ ] Create troubleshooting guide for team
- [ ] Document monitoring and alerting setup

## Team Training

- [ ] Train team on peer discovery architecture
- [ ] Train team on monitoring and troubleshooting
- [ ] Train team on common issues and solutions
- [ ] Create quick reference guide
- [ ] Set up on-call procedures

## Sign-Off

- [ ] Development team sign-off
- [ ] QA team sign-off
- [ ] Operations team sign-off
- [ ] Security team sign-off (if required)
- [ ] Product owner sign-off

## Post-Deployment

### Day 1
- [ ] Monitor operator logs continuously
- [ ] Verify all validators are discovered
- [ ] Verify config reload is working
- [ ] Check for any errors or warnings

### Week 1
- [ ] Monitor performance metrics
- [ ] Verify no issues with peer discovery
- [ ] Collect feedback from team
- [ ] Document any issues found

### Month 1
- [ ] Review performance metrics
- [ ] Analyze logs for patterns
- [ ] Optimize if needed
- [ ] Plan for future enhancements

## Success Criteria

- ✅ All validators are automatically discovered
- ✅ ConfigMap is updated when validators are added/removed
- ✅ Config reload is triggered for healthy validators
- ✅ No errors in operator logs
- ✅ Minimal performance impact
- ✅ Team is trained and confident
- ✅ Monitoring and alerting are in place

## Additional Resources

- **Quick Start**: `docs/QUICK_START_PEER_DISCOVERY.md`
- **Full Documentation**: `docs/peer-discovery.md`
- **Implementation Details**: `PEER_DISCOVERY_IMPLEMENTATION.md`
- **Examples**: `examples/peer-discovery-example.yaml`
- **Summary**: `IMPLEMENTATION_SUMMARY.md`

## Notes

- Peer discovery runs in a separate async task (doesn't block reconciliation)
- ConfigMap is only updated when peers actually change
- Config reload only happens for healthy validators
- Watcher automatically restarts on errors
- All operations are logged for debugging

## Questions?

Refer to the documentation or check the operator logs for detailed information about peer discovery operations.
