Sulap Artisan Production Starter
This package turns your current single-file system into a free production starter using:
Netlify Free for hosting
Supabase Free for database, auth-ready tables, and storage
GitHub Free for version control and deploys
Files
`public/index.html` — your portal, now with Supabase loading support.
`public/config.js` — paste your Supabase project URL and anon key here.
`database/supabase-schema.sql` — run this in Supabase SQL Editor.
`netlify.toml` — Netlify deployment config.
Step 1 — Create Supabase project
Go to Supabase.
Create a new project.
Open SQL Editor.
Paste everything from `database/supabase-schema.sql`.
Click Run.
This creates:
site settings
vendors
events
event applications
payments
parking records
vendor passes
file records
storage buckets
Step 2 — Add Supabase keys
In Supabase:
Go to Project Settings → API.
Copy the Project URL.
Copy the anon public key.
Open `public/config.js`.
Replace the placeholders.
Step 3 — Test locally
Open `public/index.html` in your browser.
Expected behavior:
Before keys are added: demo mode still works.
After keys are added: Site Settings and main lists load from Supabase.
Admin → Site Settings → Save should update Supabase.
Step 4 — Upload to GitHub
Create a new GitHub repository and upload these files.
Recommended repo structure:
```text
/
  netlify.toml
  public/
    index.html
    config.js
  database/
    supabase-schema.sql
```
Step 5 — Deploy on Netlify
Go to Netlify.
Add new site → Import from Git.
Choose your GitHub repo.
Publish directory: `public`
Deploy.
Important security note before public launch
The SQL file currently includes temporary public admin-write policies so you can test quickly for free without building full auth first.
Before real vendors use it, replace those temporary policies with proper admin/vendor login policies. The database structure is ready for that next step.
Next production hardening phase
Recommended next phase:
Supabase Auth login for admin and vendors.
Admin role table.
Private storage for receipts/invoices.
Upload actual files to Supabase Storage instead of storing image data URLs.
Convert every create/update button to write directly to Supabase.
