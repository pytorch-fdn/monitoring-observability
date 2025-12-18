// SPDX-FileCopyrightText: 2025 2025 The Linux Foundation
//
// SPDX-License-Identifier: Apache-2.0

const MACHINE_TYPE_FILTER = 'includes';
const THRESHOLD = 28800;
const jsonData = dd.response.body;

// Check status code and provide helpful error message
if (dd.response.statusCode !== 200) {
  const errorMsg = `Unable to reach PyTorch HUD data source - received HTTP ${dd.response.statusCode} error. The HUD API may be experiencing issues.`;
  console.error(errorMsg);
  throw new Error(errorMsg);
}

let parsedData;
let hudError = null;

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
  console.error(hudError);
  throw new Error(hudError);
}

const highQueueItems = parsedData
  .filter(item => item.machine_type.includes(MACHINE_TYPE_FILTER) && item.avg_queue_s > THRESHOLD)
  .map(item => ({ machine_type: item.machine_type, avg_queue_s: item.avg_queue_s }));

if (highQueueItems.length > 0) {
  const machineDetails = highQueueItems
    .map(item => `${item.machine_type} (${(item.avg_queue_s / 3600).toFixed(1)}h)`)
    .join(', ');
  const message = `High queue detected for .dgx.: ${machineDetails}. machine types containing .dgx.`;
  console.error(message);
}

dd.expect(highQueueItems.length > 0).to.be.false;
