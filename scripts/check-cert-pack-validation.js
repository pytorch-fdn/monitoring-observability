// SPDX-FileCopyrightText: 2025 The Linux Foundation
//
// SPDX-License-Identifier: Apache-2.0

// Fail if any Cloudflare certificate pack is stuck in `pending_validation`.
// Cloudflare packs move through initializing -> pending_validation ->
// pending_issuance -> pending_deployment -> active. A pack that cannot satisfy
// Domain Control Validation (DCV) sits in pending_validation indefinitely while
// the zone keeps serving the old cert, so this is invisible from a TLS probe.
//
// Defensive by design (mirrors scripts/check-long-queue-lf.js): pass silently
// on any non-200 / malformed / unsuccessful response so Cloudflare API blips or
// auth hiccups don't flap this alert. Only fail on a genuine pending_validation.

const STUCK_STATUS = 'pending_validation';

let apiError = null;
let stuck = [];

if (dd.response.statusCode !== 200) {
  console.log(`Cloudflare API returned HTTP ${dd.response.statusCode} — skipping cert-pack check (transient errors should not page).`);
} else {
  let parsed;
  try {
    parsed = JSON.parse(dd.response.body);
  } catch (error) {
    apiError = `invalid JSON response (${error.message})`;
  }

  if (!apiError && (!parsed || parsed.success !== true || !Array.isArray(parsed.result))) {
    apiError = 'unexpected response shape (missing success:true or result array)';
  }

  if (apiError) {
    console.log(`Cloudflare API issue: ${apiError} — skipping cert-pack check.`);
  } else {
    stuck = parsed.result.filter(pack => pack.status === STUCK_STATUS);

    if (stuck.length > 0) {
      const details = stuck
        .map(pack => `${(pack.hosts && pack.hosts.join(', ')) || pack.id} [${pack.certificate_authority || 'unknown CA'}]`)
        .join('; ');
      console.error(`Cloudflare certificate pack(s) stuck in ${STUCK_STATUS}: ${details}`);
    }
  }
}

// Fails only when a pack is genuinely stuck; all error paths leave stuck empty and pass.
dd.expect(stuck.length > 0).to.be.false;
