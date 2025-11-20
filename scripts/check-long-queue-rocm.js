// SPDX-FileCopyrightText: 2025 2025 The Linux Foundation
//
// SPDX-License-Identifier: Apache-2.0

dd.expect(dd.response.statusCode).to.equal(200);

const MACHINE_TYPE_FILTER = '.rocm.';
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
  .filter(item => item.machine_type.includes(MACHINE_TYPE_FILTER) && item.avg_queue_s > 14400)
  .map(item => ({ machine_type: item.machine_type, avg_queue_s: item.avg_queue_s }));

if (highQueueItems.length > 0) {
  const machineDetails = highQueueItems
    .map(item => `${item.machine_type} (${item.avg_queue_s}s)`)
    .join(', ');
  const message = `High queue detected for machine types containing ${MACHINE_TYPE_FILTER}: ${machineDetails}`;
  console.error(message);
}

dd.expect(highQueueItems.length > 0).to.be.false;
