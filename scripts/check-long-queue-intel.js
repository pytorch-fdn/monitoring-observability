// SPDX-FileCopyrightText: 2025 The Linux Foundation
//
// SPDX-License-Identifier: Apache-2.0

const MACHINE_TYPE_FILTER = '.idc.';
const THRESHOLD = 21600;
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
  
  // Check if we got an error response instead of queue data
  if (!Array.isArray(parsedData)) {
    hudError = 'Unable to reach PyTorch HUD data source - received unexpected response format instead of queue data';
  }
  
  // Validate that we have the expected structure
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
  .filter(item => item.machine_type.includes(MACHINE_TYPE_FILTER) && item.avg_queue_s > THRESHOLD)
  .map(item => ({ machine_type: item.machine_type, avg_queue_s: item.avg_queue_s }));

if (highQueueItems.length > 0) {
  const machineDetails = highQueueItems
    .map(item => `${item.machine_type} (${(item.avg_queue_s / 3600).toFixed(1)}h)`)
    .join(', ');
  const message = `High queue detected for machine types containing ".idc.": ${machineDetails}`;
  console.error(message);
}

dd.expect(highQueueItems.length > 0).to.be.false;
}
