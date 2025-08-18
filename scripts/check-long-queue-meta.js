dd.expect(dd.response.statusCode).to.equal(200);
const EXCLUDED_MACHINE_PATTERNS = ['.dgx.', '.rocm.', '.s390x', '^lf\\.'];
const jsonData = dd.response.body;
const parsedData = JSON.parse(jsonData);
const highQueueItems = parsedData
  .filter(item => {
    const machineType = item.machine_type;
    return !EXCLUDED_MACHINE_PATTERNS.some(pattern =>
      pattern.startsWith('^') ?
        new RegExp(pattern).test(machineType) :
        machineType.includes(pattern)
    ) && item.avg_queue_s > 7200;
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
