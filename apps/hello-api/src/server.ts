import Fastify from 'fastify';

const app = Fastify({ logger: true });

// Liveness/readiness endpoint for Kubernetes probes later on
app.get('/healthz', async () => ({ ok: true }));

// Shows which process and user the code runs as: useful to compare Mac vs container
app.get('/', async () => ({
  hello: 'cache',
  pid: process.pid,
  uid: process.getuid?.(),
  node: process.version,
}));

// PID 1 in a container has no default signal handlers, so handle SIGTERM ourselves
for (const signal of ['SIGTERM', 'SIGINT'] as const) {
  process.on(signal, async () => {
    app.log.info({ signal }, 'shutting down');
    await app.close();
    process.exit(0);
  });
}

const port = Number(process.env.PORT ?? 3000);
// 0.0.0.0, not localhost: inside a container "localhost" is the container's own loopback
await app.listen({ host: '0.0.0.0', port });