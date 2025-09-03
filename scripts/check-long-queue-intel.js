if (dd.response.statusCode !== 200) {
  // We do not want to fail due to hud.pytorch.org API failure.
  console.log('Status code is not 200, stopping execution');
  dd.expect(true).to.equal(true);
}
else {
  const MACHINE_TYPE_FILTER = '.idc.';
  const jsonData = dd.response.body;
  const parsedData = JSON.parse(jsonData);

  const highQueueItems = parsedData
    .filter(item => item.machine_type.includes(MACHINE_TYPE_FILTER) && item.avg_queue_s > 10800)
    .map(item => ({ machine_type: item.machine_type, avg_queue_s: item.avg_queue_s }));

  if (highQueueItems.length > 0) {
    const machineDetails = highQueueItems
      .map(item => `${item.machine_type} (${item.avg_queue_s}s)`)
      .join(', ');
    const message = `High queue detected for machine types containing ${MACHINE_TYPE_FILTER}: ${machineDetails}`;
    console.error(message);
  }

  dd.expect(highQueueItems.length > 0).to.be.false;
}
