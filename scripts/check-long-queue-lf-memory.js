// SPDX-FileCopyrightText: 2025 The Linux Foundation
//
// SPDX-License-Identifier: Apache-2.0

// Monitor LF memory.ephemeral separately - chronically queued
const MACHINE_TYPE_FILTER = 'lf.linux.12xlarge.memory.ephemeral';
const THRESHOLD = 57600;  // 16 hours
const jsonData = dd.response.body;

// Pass silently on HUD API errors — HUD uptime is monitored separately.
if (dd.response.statusCode !== 200) {
  console.log(`HUD API returned HTTP ${dd.response.statusCode} — skipping queue check (HUD uptime monitored separately).`);
  dd.expect(true).to.be.true;
}

let parsedData;
let hudError = null;

if (dd.response.statusCode === 200) {
try {
  parsedData = JSON.parse(jsonData);
  
  if (!Array.isArray(parsedData)) {
    hudError = 'Unable to reach PyTorch HUD data source - received unexpected response format instead of queue data';
  }
  
  if (!hudError && parsedData.length > 0 && (!parsedData[0].machine_type || parsedData[0].avg_queue_s === undefined)) {
    hudError = 'Unable to reach PyTorch HUD data source - received data without expected machine_type or avg_queue_s fields';
  }
} catch (error) {
  if (error instanceof SyntaxError) {
    hudError = 'Unable to reach PyTorch HUD data source - received invalid JSON response';
  } else {
    hudError = `Unable to reach PyTorch HUD data source - ${error.message}`;
  }
}

if (hudError) {
  console.log(`HUD data issue: ${hudError} — skipping queue check.`);
}
}

if (dd.response.statusCode === 200 && !hudError && parsedData) {
const highQueueItems = parsedData
  .filter(item => item.machine_type === MACHINE_TYPE_FILTER && item.avg_queue_s > THRESHOLD)
  .map(item => ({ machine_type: item.machine_type, avg_queue_s: item.avg_queue_s }));

if (highQueueItems.length > 0) {
  const machineDetails = highQueueItems
    .map(item => `${item.machine_type} (${(item.avg_queue_s / 3600).toFixed(1)}h)`)
    .join(', ');
  const message = `High queue detected for LF memory.ephemeral: ${machineDetails}. Normal range: 11-14h`;
  console.error(message);
}

dd.expect(highQueueItems.length > 0).to.be.false;
}
