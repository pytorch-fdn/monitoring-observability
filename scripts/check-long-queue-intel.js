// SPDX-FileCopyrightText: 2025 2025 The Linux Foundation
//
// SPDX-License-Identifier: Apache-2.0

dd.expect(dd.response.statusCode).to.equal(200);

const MACHINE_TYPE_FILTER = '.idc.';
const jsonData = dd.response.body;
const parsedData = JSON.parse(jsonData);

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
