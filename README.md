# BIDBAYAN — Local auction MVP

## Start
Double-click `Start-BIDBAYAN.cmd`, then open http://127.0.0.1:4173 in a browser.

## Accounts and auction data
Accounts are stored locally in `data/users.json` with scrypt password hashes. Auction data, accepted bids, and payment orders are stored in JSON files under `data/`. Sign in to bid or list an item.

## PayMongo test checkout
1. Create a PayMongo account and copy a **test** secret key from its developer dashboard.
2. Copy `.env.example` to `.env` and fill in `PAYMONGO_SECRET_KEY`.
3. For webhook delivery, deploy the server to a publicly reachable HTTPS address, register `https://your-domain/webhooks/paymongo` in PayMongo, subscribe to `checkout_session.payment.paid`, and put the endpoint signing secret in `PAYMONGO_WEBHOOK_SECRET`.
4. Set `PUBLIC_URL` to the public HTTPS site origin, then restart the server.

Never commit `.env` or expose secret keys in browser code. Checkout is for the winning bidder after an auction ends; the PayMongo webhook is the source of truth for paid status. PayMongo marketplace split payouts require separate account activation/configuration, so this MVP collects payment to the platform account and does not automatically pay sellers.

This is still a local MVP. Public launch also needs hosting, HTTPS, a production database/session store, seller verification, delivery workflows, and marketplace policies. Don't use real passwords in a development install.

## Docker deployment preparation
The app can now run in a container and listens on the platform-provided `PORT` on all interfaces. Configure a persistent disk mounted at `/app/data`; that folder holds user, auction, and order records. Set `PAYMONGO_SECRET_KEY`, `PAYMONGO_WEBHOOK_SECRET`, and `PUBLIC_URL` in the hosting platform's secret/environment settings. The `/healthz` endpoint returns a health response.

For local container preview, from the `outputs` folder run:

```powershell
docker build -t bidbayan .
docker run --rm -p 4173:4173 -v "${PWD}/data:/app/data" bidbayan
```

Then visit http://127.0.0.1:4173. The source `.env` remains outside the image and `.dockerignore` excludes it.

## Render deployment
The `render.yaml` file is a Render Blueprint for a Docker web service, with a persistent disk mounted at `/app/data` and health checks on `/healthz`. Render requires a paid web service plan for attached persistent disks, so review the plan and disk charges in your Render Dashboard before creating the Blueprint. This file does not create a service by itself.

To deploy, put the contents of `outputs` in a Git repository, connect that repository in Render, and create a Blueprint from `render.yaml`. Render will prompt for your PayMongo test secret key and generate a temporary webhook secret. After the service is live, add `https://YOUR-SERVICE.onrender.com/webhooks/paymongo` as a PayMongo webhook endpoint for `checkout_session.payment.paid`, then replace the generated `PAYMONGO_WEBHOOK_SECRET` in Render with that endpoint signing secret and redeploy. Set `PUBLIC_URL` in Render to your actual public origin if you use a custom domain.

This file-based MVP uses a single service instance because its persistent disk cannot be shared or used for horizontal scaling. Upgrade to a managed database and a persistent session store before growing beyond a small beta.

