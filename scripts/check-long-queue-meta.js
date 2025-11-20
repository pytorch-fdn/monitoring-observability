// SPDX-FileCopyrightText: 2025 2025 The Linux Foundation
//
// SPDX-License-Identifier: Apache-2.0

dd.expect(dd.response.statusCode).to.equal(200);
const EXCLUDED_MACHINE_PATTERNS = ['.dgx.', '.idc.', '.rocm.', '.s390x', '^lf\.', '^linux.aws.h100'];
const jsonData = dd.response.body;

let parsedData;
try {
  parsedData = JSON.parse(jsonData);
  
  // Check if we got an error response instead of queue data
  if (!Array.isArray(parsedData)) {
    throw new Error('Unable to reach PyTorch HUD data source - received unexpected response format instead of queue data');
  }
  
  // Validate that we have the expected structure
  if (parsedData.length > 0 && (!parsedData[0].machine_type || parsedData[0].avg_queue_s === undefined)) {
    throw new Error('Unable to reach PyTorch HUD data source - received data without expected machine_type or avg_queue_s fields');
  }
} catch (error) {
  if (error instanceof SyntaxError) {
    throw new Error('Unable to reach PyTorch HUD data source - received invalid JSON response');
  }
  throw error;
}

const highQueueItems = parsedData
  .filter(item => {
    const machineType = item.machine_type;
    return !EXCLUDED_MACHINE_PATTERNS.some(pattern =>
      pattern.startsWith('^') ?
        new RegExp(pattern).test(machineType) :
        machineType.includes(pattern)
    ) && item.avg_queue_s > 14400;
  })
  .map(item => ({ machine_type: item.machine_type, avg_queue_s: item.avg_queue_s }));
if (highQueueItems.length > 0) {
  const machineDetails = highQueueItems
    .map(item => `${item.machine_type} (${item.avg_queue_s}s)`)
    .join(', ');
  const message = `High queue detected for machine types: ${machineDetails}`;
  console.error(message);
}
dd.expect(highQueueItems.length > 0).to.be.false;
