#234 Service Mesh Integration: Istio/Linkerd mTLS Enforcement
Repo Avatar
OtowoOrg/Stellar-K8s
🔴 Difficulty: High (200 Points)
Move beyond basic K8s networking and integrate with a Service Mesh for advanced traffic control and mTLS.

✅ Acceptance Criteria
Provide PeerAuthentication and DestinationRule manifests for Istio.
Ensure the operator is compatible with sidecar injection.
Implement circuit breaking and retries for cross-node communication via the mesh config.
Verify through E2E tests that all traffic is encrypted and authenticated via the mesh.