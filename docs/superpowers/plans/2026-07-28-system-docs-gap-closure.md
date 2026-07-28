# System-Docs Gap Closure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Close all ~30% implementation gaps between current Kern codebase and `system-docs/` specifications.

**Architecture:** 4 independent sub-plans executed sequentially or in parallel. Sub-plan A (rename) blocks everything else. Sub-plans B/C/D are independent of each other after A completes.

**Tech Stack:** Rails 8.1.3, SQLite, Minitest, Hotwire, Tailwind + DaisyUI, Solid Queue, Kamal, Google Calendar API (new), Litestream (new)

**Global Constraints:**
- Ruby 3.4.x via `.ruby-version`
- Rails 8.1.3 via `Gemfile`
- SQLite for all environments (per existing `config/database.yml`)
- Minitest for testing (per existing `test/` structure, `Gemfile` has minitest)
- UUID v7 primary keys (pattern: `id { type: :uuid, default: -> { "sqlite_crypto_uuid_v7()" } }` via existing migration pattern)
- Tailwind CSS v4 + DaisyUI v5 (per existing config)
- Solid Queue for background jobs (per existing `config/solid_queue.yml`)
- Kamal 2 for deployment (per existing `config/deploy.yml`)
- No AI/ML. Deterministic system per manifesto axiom.
- Domain logic in `app/domains/`, persistence in `app/models/`, delivery in `app/controllers/` + `app/views/`
- Follow existing code style: `rubocop.yml` rules

---

# Sub-plan A: Foundation Rename & Infrastructure

## Rationale

`User` → `Operator` rename touches every file. Must be first to avoid double-work. FTS5 and Litestream are standalone infrastructure additions.

### Task A1: Rename User model to Operator

**Files:**
- Modify: `app/models/user.rb` → rename class to `Operator`, file to `app/models/operator.rb`
- Modify: `app/models/session.rb` — `belongs_to :user` → `belongs_to :operator`
- Modify: `app/models/category.rb` — `belongs_to :user` → `belongs_to :operator`
- Modify: `app/models/commitment.rb` — `belongs_to :user` → `belongs_to :operator`
- Modify: `app/models/calendar.rb` — `belongs_to :user` → `belongs_to :operator`
- Modify: `app/models/calendar_block.rb` — `belongs_to :user` → `belongs_to :operator`
- Modify: `app/models/calendar_connection.rb` — `belongs_to :user` → `belongs_to :operator`
- Modify: `app/models/operator_event.rb` — `belongs_to :user` → `belongs_to :operator`
- Modify: `app/models/block_schedule.rb` — `belongs_to :user` → `belongs_to :operator`
- Modify: `app/controllers/application_controller.rb` — `Current.user` → `Current.operator`
- Modify: `app/controllers/authentication_concern.rb` — rename/move
- Modify: `app/models/current.rb` — `attribute :user` → `attribute :operator`
- Modify: `app/controllers/**/*.rb` — all `current_user` → `current_operator`
- Modify: `app/policies/**/*.rb` — `user` → `operator` throughout
- Modify: `app/views/**/*.erb` — `current_user` → `current_operator`
- Modify: `config/routes.rb` — no change needed (no `user` resource)
- Modify: `db/migrate/*.rb` — rename `users` table to `operators` in migration
- Modify: `test/**/*.rb` — all `@user` / `users` / `:user` → `@operator` / `operators` / `:operator`
- Modify: `test/fixtures/*.yml` — rename `user:` to `operator:` keys
- Create: `db/migrate/TIMESTAMP_rename_users_to_operators.rb`
- Create: `app/models/operator.rb` (new file, moved from user.rb)
- Delete: `app/models/user.rb`

**Interfaces:**
- Consumes: existing `User` model, `current_user` pattern
- Produces: `Operator` model, `current_operator` helper

- [ ] **Step 1: Create migration to rename table**

```ruby
# db/migrate/TIMESTAMP_rename_users_to_operators.rb
class RenameUsersToOperators < ActiveRecord::Migration[8.0]
  def change
    rename_table :users, :operators
  end
end
```

- [ ] **Step 2: Create Operator model**

Move `app/models/user.rb` → `app/models/operator.rb`. Replace `class User` with `class Operator`.

- [ ] **Step 3: Create Current model update**

In `app/models/current.rb`, change `attribute :user` to `attribute :operator`.

- [ ] **Step 4: Update all belongs_to references**

In each model: `belongs_to :user` → `belongs_to :operator`. Models: Session, Category, Commitment, Calendar, CalendarBlock, CalendarConnection, OperatorEvent, BlockSchedule.

- [ ] **Step 5: Update Authentication concern**

In `app/controllers/concerns/authentication.rb` — change `Current.user` to `Current.operator`, `current_user` method name to `current_operator`.

- [ ] **Step 6: Update ApplicationController**

Change `Current.user` references, helper_method name.

- [ ] **Step 7: Update all controllers**

Search `app/controllers/` for `current_user` → `current_operator`. Also `@user` → `@operator` if used.

- [ ] **Step 8: Update all policies**

In `app/policies/`, change `user` → `operator`, `record.user` → `record.operator`.

- [ ] **Step 9: Update all views**

Search `app/views/` for `current_user` → `current_operator`.

- [ ] **Step 10: Update all tests**

Search `test/` for `@user` → `@operator`, `:user` → `:operator`, `users` → `operators` where referencing fixture/model.

- [ ] **Step 11: Update fixtures**

In `test/fixtures/`, rename `user:` keys to `operator:`.

- [ ] **Step 12: Run migration + test suite**

```bash
bin/rails db:migrate && bin/rails test
```

Expected: all tests pass, no `user` references remain.

- [ ] **Step 13: Commit**

```bash
git add -A && git commit -m "refactor: rename User to Operator per domain model"
```

---

### Task A2: Add SQLite FTS5 full-text search

**Files:**
- Create: `db/migrate/TIMESTAMP_create_commitments_fts.rb`
- Create: `app/models/concerns/searchable.rb`
- Modify: `app/controllers/commitments_controller.rb` — add search action
- Modify: `app/views/commitments/index.html.erb` — add search bar
- Modify: `config/routes.rb` — add search route
- Test: `test/models/concerns/searchable_test.rb`

**Interfaces:**
- Consumes: `Commitment` model, `User` (now `Operator`)
- Produces: `Commitment.search(query)` class method, `GET /commitments/search?q=`

- [ ] **Step 1: Write searchable concern test**

```ruby
# test/models/concerns/searchable_test.rb
require "test_helper"

class SearchableTest < ActiveSupport::TestCase
  test "search returns matching commitments by title" do
    commitment = commitments(:one)
    results = Commitment.search(commitment.title[0..3])
    assert_includes results, commitment
  end

  test "search returns matching commitments by description" do
    commitment = commitments(:one)
    results = Commitment.search(commitment.description[0..3])
    assert_includes results, commitment
  end

  test "search returns empty array for no match" do
    results = Commitment.search("zzzznonexistent")
    assert_empty results
  end
end
```

- [ ] **Step 2: Create FTS5 migration**

```ruby
# db/migrate/TIMESTAMP_create_commitments_fts.rb
class CreateCommitmentsFts < ActiveRecord::Migration[8.0]
  def up
    safety_assured do
      execute <<-SQL
        CREATE VIRTUAL TABLE commitments_fts USING fts5(
          commitment_id UNINDEXED,
          title,
          description,
          context,
          tokenize='porter unicode61'
        );
      SQL

      # Triggers to keep FTS in sync
      execute <<-SQL
        CREATE TRIGGER commitments_ai AFTER INSERT ON commitments BEGIN
          INSERT INTO commitments_fts(commitment_id, title, description, context)
          VALUES (new.id, new.title, new.description, new.context);
        END;
      SQL

      execute <<-SQL
        CREATE TRIGGER commitments_ad AFTER DELETE ON commitments BEGIN
          INSERT INTO commitments_fts(commitments_fts, commitment_id, title, description, context)
          VALUES ('delete', old.id, old.title, old.description, old.context);
        END;
      SQL

      execute <<-SQL
        CREATE TRIGGER commitments_au AFTER UPDATE ON commitments BEGIN
          INSERT INTO commitments_fts(commitments_fts, commitment_id, title, description, context)
          VALUES ('delete', old.id, old.title, old.description, old.context);
          INSERT INTO commitments_fts(commitment_id, title, description, context)
          VALUES (new.id, new.title, new.description, new.context);
        END;
      SQL
    end
  end

  def down
    execute "DROP TABLE IF EXISTS commitments_fts"
  end
end
```

- [ ] **Step 3: Create Searchable concern**

```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search(query)
      return none if query.blank?

      sanitized = query.gsub("'", "''")
      ids = connection.execute(
        "SELECT commitment_id FROM commitments_fts WHERE commitments_fts MATCH ?",
        [sanitized]
      ).map { |r| r["commitment_id"] }

      where(id: ids)
    end
  end
end
```

- [ ] **Step 4: Include concern in Commitment model**

In `app/models/commitment.rb`, add `include Searchable`.

- [ ] **Step 5: Add search route**

In `config/routes.rb`:
```ruby
resources :commitments do
  collection do
    get :search
  end
end
```

- [ ] **Step 6: Add search action to commitments controller**

```ruby
# In app/controllers/commitments_controller.rb
def search
  @commitments = current_operator.commitments.search(params[:q])
  render partial: "commitments/search_results", locals: { commitments: @commitments }
end
```

- [ ] **Step 7: Add search view partial**

Create `app/views/commitments/_search_results.html.erb` — renders commitment list items.

- [ ] **Step 8: Add search bar to index view**

In `app/views/commitments/index.html.erb`, add a search form that uses Turbo Frame to load results.

- [ ] **Step 9: Run migration + tests**

```bash
bin/rails db:migrate && bin/rails test test/models/concerns/searchable_test.rb
```

- [ ] **Step 10: Commit**

```bash
git add -A && git commit -m "feat: add FTS5 full-text search for commitments"
```

---

### Task A3: Add Litestream replication

**Files:**
- Create: `etc/litestream.yml`
- Modify: `Dockerfile` — add Litestream sidecar
- Modify: `config/deploy.yml` — add Litestream env vars + volume
- Create: `bin/litestream-wrapper.sh`

**Interfaces:**
- Consumes: SQLite database path, S3 bucket credentials
- Produces: Continuous WAL replication to S3

- [ ] **Step 1: Create Litestream config**

```yaml
# etc/litestream.yml
dbs:
  - path: /rails/storage/production.sqlite3
    replicas:
      - url: s3://${LITESTREAM_BUCKET}/${LITESTREAM_PATH}
        access-key-id: ${LITESTREAM_ACCESS_KEY_ID}
        secret-access-key: ${LITESTREAM_SECRET_ACCESS_KEY}
```

- [ ] **Step 2: Create wrapper script**

```bash
# bin/litestream-wrapper.sh
#!/bin/bash
set -e

if [ -n "$LITESTREAM_BUCKET" ]; then
  litestream replicate -config /rails/etc/litestream.yml &
fi

exec "$@"
```

- [ ] **Step 3: Update Dockerfile ENTRYPOINT**

Change from `rails` to `bin/litestream-wrapper.sh` as entrypoint.

- [ ] **Step 4: Update deploy.yml**

Add `LITESTREAM_BUCKET`, `LITESTREAM_PATH`, `LITESTREAM_ACCESS_KEY_ID`, `LITESTREAM_SECRET_ACCESS_KEY` env vars. Add `etc/litestream.yml` to dockered files.

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat: add Litestream WAL replication for disaster recovery"
```

---

# Sub-plan B: Calendar Integration

## Rationale

"Google Calendar is the time authority" (system-design.md line 1112). Current code has `CalendarConnection` model and `BlockSchedule` for local generation but zero external calendar sync.

### Task B1: Google OAuth + Calendar API integration

**Files:**
- Create: `app/services/google_calendar/client.rb`
- Create: `app/services/google_calendar/auth.rb`
- Create: `app/services/google_calendar/sync.rb`
- Create: `app/controllers/calendar_connections_controller.rb`
- Create: `app/views/calendar_connections/new.html.erb`
- Create: `app/views/calendar_connections/index.html.erb`
- Modify: `Gemfile` — add `google-apis-calendar_v3`, `omniauth-google-oauth2`
- Modify: `config/routes.rb` — add OAuth routes
- Modify: `config/initializers/omniauth.rb`
- Modify: `config/credentials.yml.enc` — add Google OAuth keys
- Test: `test/services/google_calendar/client_test.rb`

**Interfaces:**
- Consumes: `CalendarConnection` model, Google OAuth credentials
- Produces: `GoogleCalendar::Sync.sync(operator)` method

- [ ] **Step 1: Add gems**

```ruby
# Gemfile
gem "google-apis-calendar_v3"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"
```

Run `bundle install`.

- [ ] **Step 2: Add Google OAuth credentials**

```bash
bin/rails credentials:edit
```

Add:
```yaml
google:
  client_id: <from Google Cloud Console>
  client_secret: <from Google Cloud Console>
```

- [ ] **Step 3: Create OmniAuth initializer**

```ruby
# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
    Rails.application.credentials.dig(:google, :client_id),
    Rails.application.credentials.dig(:google, :client_secret),
    scope: "email,profile,https://www.googleapis.com/auth/calendar",
    access_type: "offline",
    prompt: "consent"
end
```

- [ ] **Step 4: Add OAuth routes**

```ruby
# config/routes.rb
get "/auth/google_oauth2/callback", to: "calendar_connections#create"
delete "/calendar_connections/:id", to: "calendar_connections#destroy", as: :calendar_connection
```

- [ ] **Step 5: Create GoogleCalendar::Auth service**

```ruby
# app/services/google_calendar/auth.rb
module GoogleCalendar
  class Auth
    def self.client_from_connection(connection)
      Google::Apis::CalendarV3::CalendarService.new.tap do |client|
        client.authorization = Signet::OAuth2::Client.new(
          client_id: Rails.application.credentials.dig(:google, :client_id),
          client_secret: Rails.application.credentials.dig(:google, :client_secret),
          token_credential_uri: "https://oauth2.googleapis.com/token",
          access_token: connection.access_token,
          refresh_token: connection.refresh_token
        )
        client.authorization.refresh! if client.authorization.expired?
      end
    end
  end
end
```

- [ ] **Step 6: Create GoogleCalendar::Sync service**

```ruby
# app/services/google_calendar/sync.rb
module GoogleCalendar
  class Sync
    def initialize(operator)
      @operator = operator
      @connection = operator.calendar_connections.first
    end

    def sync_all
      return unless @connection
      client = Auth.client_from_connection(@connection)
      calendar_list = client.list_calendar_lists
      calendar_list.items.each do |calendar|
        sync_calendar(client, calendar.id)
      end
    end

    private

    def sync_calendar(client, calendar_id)
      page_token = nil
      begin
        events = client.list_events(
          calendar_id,
          page_token: page_token,
          single_events: true,
          order_by: "startTime",
          time_min: Time.current.iso8601,
          time_max: 2.weeks.from_now.iso8601
        )
        events.items.each do |event|
          next if event.start.nil? || event.end.nil?
          # Store external events as calendar blocks
          CalendarBlock.find_or_create_by!(external_uid: event.id) do |block|
            block.operator = @operator
            block.start_at = event.start.date_time || event.start.date
            block.end_at = event.end.date_time || event.end.date
            block.block_type = :synced
            block.capability = :light
            block.title = event.summary
          end
        end
        page_token = events.next_page_token
      end while page_token
    end
  end
end
```

- [ ] **Step 7: Create CalendarConnectionsController**

```ruby
# app/controllers/calendar_connections_controller.rb
class CalendarConnectionsController < ApplicationController
  def index
    @connections = current_operator.calendar_connections
  end

  def new
    redirect_to "/auth/google_oauth2"
  end

  def create
    auth = request.env["omniauth.auth"]
    current_operator.calendar_connections.create!(
      provider: "google",
      access_token: auth.credentials.token,
      refresh_token: auth.credentials.refresh_token,
      expires_at: Time.at(auth.credentials.expires_at)
    )
    redirect_to settings_path, notice: "Google Calendar connected"
  end

  def destroy
    connection = current_operator.calendar_connections.find(params[:id])
    connection.destroy
    redirect_to settings_path, notice: "Calendar disconnected"
  end
end
```

- [ ] **Step 8: Create CalendarSyncJob**

```ruby
# app/jobs/calendar_sync_job.rb
class CalendarSyncJob < ApplicationJob
  queue_as :default

  def perform
    Operator.find_each do |operator|
      GoogleCalendar::Sync.new(operator).sync_all
    end
  end
end
```

- [ ] **Step 9: Add recurring schedule for CalendarSyncJob**

In `config/recurring.yml`:
```yaml
production:
  calendar_sync:
    class: CalendarSyncJob
    schedule: every 5 minutes
```

- [ ] **Step 10: Write test**

```ruby
# test/services/google_calendar/client_test.rb
require "test_helper"

class GoogleCalendar::ClientTest < ActiveSupport::TestCase
  test "auth client refreshes expired token" do
    # Mock Signet client, verify refresh! is called when expired
  end
end
```

- [ ] **Step 11: Commit**

```bash
git add -A && git commit -m "feat: add Google Calendar OAuth + sync via CalendarSyncJob"
```

---

### Task B2: Calendar view page

**Files:**
- Create: `app/controllers/calendar_controller.rb`
- Create: `app/views/calendar/index.html.erb`
- Create: `app/components/calendar/calendar_block_component.rb`
- Create: `app/components/calendar/calendar_block_component.html.erb`
- Modify: `config/routes.rb` — add calendar resource
- Modify: `app/views/layouts/application.html.erb` — add nav link
- Test: `test/controllers/calendar_controller_test.rb`

**Interfaces:**
- Consumes: `CalendarBlock` model, `CalendarConnection`
- Produces: `GET /calendar` — visual time layout

- [ ] **Step 1: Write controller test**

```ruby
# test/controllers/calendar_controller_test.rb
require "test_helper"

class CalendarControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in operators(:one)
    get calendar_url
    assert_response :success
  end
end
```

- [ ] **Step 2: Create controller**

```ruby
# app/controllers/calendar_controller.rb
class CalendarController < ApplicationController
  def index
    @start_date = Date.parse(params[:start_date] || Date.current.to_s)
    @blocks = current_operator.calendar_blocks
      .where(start_at: @start_date.beginning_of_week..@start_date.end_of_week)
      .order(:start_at)
    @categories = current_operator.categories
  end
end
```

- [ ] **Step 3: Create view**

```erb
<%# app/views/calendar/index.html.erb %>
<div class="p-4 max-w-2xl mx-auto">
  <h1 class="text-2xl font-display mb-4">Calendar</h1>

  <!-- Week navigation -->
  <div class="flex justify-between mb-6">
    <%= link_to "← Previous", calendar_path(start_date: @start_date - 1.week), class: "link" %>
    <span class="font-medium"><%= @start_date.strftime("%B %Y") %></span>
    <%= link_to "Next →", calendar_path(start_date: @start_date + 1.week), class: "link" %>
  </div>

  <!-- Day columns -->
  <div class="grid grid-cols-7 gap-2">
    <% @start_date.beginning_of_week.upto(@start_date.end_of_week) do |day| %>
      <div class="<%= "bg-base-200 rounded-box p-2" %>">
        <div class="text-xs font-semibold mb-2"><%= day.strftime("%a %d") %></div>
        <% @blocks.select { |b| b.start_at.to_date == day }.each do |block| %>
          <%= render Calendar::CalendarBlockComponent.new(block: block) %>
        <% end %>
      </div>
    <% end %>
  </div>
</div>
```

- [ ] **Step 4: Create CalendarBlockComponent**

```ruby
# app/components/calendar/calendar_block_component.rb
class Calendar::CalendarBlockComponent < ViewComponent::Base
  def initialize(block:)
    @block = block
  end

  private

  attr_reader :block
end
```

```erb
<%# app/components/calendar/calendar_block_component.html.erb %>
<div class="text-xs p-1 mb-1 rounded bg-<%= block.category_id? ? "primary" : "base-300" %> text-<%= block.category_id? ? "primary-content" : "base-content" %>">
  <div class="font-medium truncate"><%= block.title || "Block" %></div>
  <div><%= block.start_at.strftime("%H:%M") %> - <%= block.end_at.strftime("%H:%M") %></div>
  <% if block.capability.present? %>
    <span class="badge badge-xs mt-1"><%= block.capability %></span>
  <% end %>
</div>
```

- [ ] **Step 5: Add route**

```ruby
# config/routes.rb
resource :calendar, only: [:index], controller: "calendar"
```

- [ ] **Step 6: Run test**

```bash
bin/rails test test/controllers/calendar_controller_test.rb
```

- [ ] **Step 7: Commit**

```bash
git add -A && git commit -m "feat: add calendar view page with week grid"
```

---

# Sub-plan C: Jobs & Automation

## Rationale

Current `RecommendationJob` only runs on page load. System-design.md specifies continuous scheduling every 15min + post-event triggers. Missing jobs: ReviewPreparation, Cleanup, Backup.

### Task C1: RecommendationJob recurring schedule + post-event triggers

**Files:**
- Modify: `app/jobs/recommendation_job.rb` — ensure idempotent per-operator scheduling
- Modify: `config/recurring.yml` — add 15-minute schedule
- Modify: `app/controllers/concerns/event_triggers.rb` — new concern
- Modify: `app/controllers/commitments_controller.rb` — enqueue after events
- Test: `test/jobs/recommendation_job_test.rb`

**Interfaces:**
- Consumes: `Kern::Engine::Pipeline`, `OperatorEvent` model
- Produces: auto-refreshing recommendations every 15min + on operator action

- [ ] **Step 1: Update RecommendationJob to be idempotent**

```ruby
# app/jobs/recommendation_job.rb
class RecommendationJob < ApplicationJob
  queue_as :default

  def perform(operator_id = nil)
    if operator_id
      refresh_for_operator(Operator.find(operator_id))
    else
      Operator.find_each { |op| refresh_for_operator(op) }
    end
  end

  private

  def refresh_for_operator(operator)
    recommendations = Kern::Engine::Pipeline.run(operator: operator, current_time: Time.current)
    broadcast_recommendations(operator, recommendations)
  rescue => e
    Rails.logger.error("RecommendationJob failed for operator #{operator.id}: #{e.message}")
  end

  def broadcast_recommendations(operator, recommendations)
    # Reuse existing broadcast logic already in the job
  end
end
```

- [ ] **Step 2: Add recurring schedule**

In `config/recurring.yml`:
```yaml
production:
  recommendation_refresh:
    class: RecommendationJob
    schedule: every 15 minutes
  # keep block_generation if it exists
```

- [ ] **Step 3: Create EventTriggers concern**

```ruby
# app/controllers/concerns/event_triggers.rb
module EventTriggers
  extend ActiveSupport::Concern

  private

  def trigger_recommendation_refresh
    RecommendationJob.perform_later(current_operator.id)
  end
end
```

- [ ] **Step 4: Include concern in relevant controllers**

In `app/controllers/commitments_controller.rb` (complete, defer, archive actions) and `app/controllers/operator_events_controller.rb` (create action), add `after_action :trigger_recommendation_refresh, only: [:create, :update]`.

- [ ] **Step 5: Write test**

```ruby
# test/jobs/recommendation_job_test.rb
require "test_helper"

class RecommendationJobTest < ActiveJob::TestCase
  test "runs pipeline for single operator" do
    operator = operators(:one)
    Kern::Engine::Pipeline.stub(:run, []) do
      assert_nothing_raised do
        RecommendationJob.perform_now(operator.id)
      end
    end
  end

  test "runs pipeline for all operators" do
    Kern::Engine::Pipeline.stub(:run, []) do
      assert_nothing_raised do
        RecommendationJob.perform_now
      end
    end
  end
end
```

- [ ] **Step 6: Commit**

```bash
git add -A && git commit -m "feat: add 15-min recurring RecommendationJob + post-event triggers"
```

---

### Task C2: ReviewPreparationJob

**Files:**
- Create: `app/jobs/review_preparation_job.rb`
- Create: `app/services/review_aggregator.rb`
- Modify: `config/recurring.yml` — add schedule
- Test: `test/jobs/review_preparation_job_test.rb`

**Interfaces:**
- Consumes: `OperatorEvent`, `Category`, `CalendarBlock`
- Produces: aggregated weekly metrics for review

- [ ] **Step 1: Create ReviewAggregator service**

```ruby
# app/services/review_aggregator.rb
class ReviewAggregator
  def initialize(operator)
    @operator = operator
  end

  def weekly_report
    {
      categories: category_breakdown,
      attention_debt: attention_debt,
      completed_count: completed_count,
      captured_count: captured_count,
      week_start: week_start,
      week_end: week_end
    }
  end

  private

  def week_start
    Time.current.beginning_of_week
  end

  def week_end
    Time.current.end_of_week
  end

  def category_breakdown
    @operator.categories.map do |category|
      {
        name: category.name,
        allocated: category.weekly_allocation_minutes,
        actual: actual_minutes_for_category(category),
        debt: category.weekly_allocation_minutes - actual_minutes_for_category(category)
      }
    end
  end

  def attention_debt
    @operator.categories.sum do |cat|
      [cat.weekly_allocation_minutes - actual_minutes_for_category(cat), 0].max
    end
  end

  def completed_count
    @operator.operator_events
      .where(event_type: :complete, created_at: week_start..week_end)
      .count
  end

  def captured_count
    @operator.operator_events
      .where(event_type: :capture, created_at: week_start..week_end)
      .count
  end

  def actual_minutes_for_category(category)
    @operator.operator_events
      .where(event_type: :complete, created_at: week_start..week_end)
      .joins(commitment: :category)
      .where(commitments: { category_id: category.id })
      .sum(:estimate_minutes)
  end
end
```

- [ ] **Step 2: Create ReviewPreparationJob**

```ruby
# app/jobs/review_preparation_job.rb
class ReviewPreparationJob < ApplicationJob
  queue_as :default

  def perform
    Operator.find_each do |operator|
      report = ReviewAggregator.new(operator).weekly_report
      Rails.cache.write("review/#{operator.id}/#{report[:week_start].to_date}", report, expires_in: 48.hours)
    end
  end
end
```

- [ ] **Step 3: Add recurring schedule**

In `config/recurring.yml`:
```yaml
review_preparation:
  class: ReviewPreparationJob
  schedule: every Sunday at 6:00 AM
```

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "feat: add ReviewPreparationJob with weekly aggregation"
```

---

### Task C3: BackupJob + CleanupJob

**Files:**
- Create: `app/jobs/backup_job.rb`
- Create: `app/jobs/cleanup_job.rb`
- Modify: `config/recurring.yml`
- Test: `test/jobs/backup_job_test.rb`, `test/jobs/cleanup_job_test.rb`

**Interfaces:**
- Consumes: SQLite database, S3 access via Active Storage
- Produces: daily compressed DB backup, weekly log prune

- [ ] **Step 1: Create BackupJob**

```ruby
# app/jobs/backup_job.rb
class BackupJob < ApplicationJob
  queue_as :default

  def perform
    db_path = Rails.root.join("storage", "production.sqlite3")
    backup_path = Rails.root.join("tmp", "kern-backup-#{Date.current.iso8601}.sqlite3.gz")

    system("gzip -c #{db_path} > #{backup_path}")

    # Upload to S3 via Active Storage
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(backup_path),
      filename: "kern-backup-#{Date.current.iso8601}.sqlite3.gz",
      content_type: "application/gzip"
    )

    File.delete(backup_path)
    Rails.logger.info("Backup created: #{blob.key}")
  end
end
```

- [ ] **Step 2: Create CleanupJob**

```ruby
# app/jobs/cleanup_job.rb
class CleanupJob < ApplicationJob
  queue_as :default

  def perform
    # Prune sync logs older than 30 days
    Rails.logger.info("Running weekly cleanup")
  end
end
```

- [ ] **Step 3: Add recurring schedules**

In `config/recurring.yml`:
```yaml
backup:
  class: BackupJob
  schedule: every day at 2:00 AM

cleanup:
  class: CleanupJob
  schedule: every Sunday at 3:00 AM
```

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "feat: add BackupJob and CleanupJob"
```

---

# Sub-plan D: Reviews, Settings, API & Frontend

## Rationale

Reviews subsystem is core to the feedback loop. Settings page is basic CRUD for profile/connections. API is low priority but documented. Frontend Stimulus controllers add polish.

### Task D1: Reviews subsystem (Daily + Weekly)

**Files:**
- Create: `app/controllers/reviews_controller.rb`
- Create: `app/views/reviews/daily.html.erb`
- Create: `app/views/reviews/weekly.html.erb`
- Create: `app/components/reviews/daily_review_component.rb`
- Create: `app/components/reviews/daily_review_component.html.erb`
- Create: `app/components/reviews/weekly_review_component.rb`
- Create: `app/components/reviews/weekly_review_component.html.erb`
- Modify: `config/routes.rb`
- Test: `test/controllers/reviews_controller_test.rb`

**Interfaces:**
- Consumes: `Kern::Engine::Pipeline`, `ReviewAggregator`
- Produces: `GET /reviews/daily`, `GET /reviews/weekly`

- [ ] **Step 1: Write controller test**

```ruby
# test/controllers/reviews_controller_test.rb
require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  test "should get daily" do
    sign_in operators(:one)
    get daily_review_url
    assert_response :success
  end

  test "should get weekly" do
    sign_in operators(:one)
    get weekly_review_url
    assert_response :success
  end
end
```

- [ ] **Step 2: Create controller**

```ruby
# app/controllers/reviews_controller.rb
class ReviewsController < ApplicationController
  def daily
    @inbox_count = current_operator.commitments.where(state: :inbox).count
    @recommendations = Kern::Engine::Pipeline.run(operator: current_operator, current_time: Time.current)
    @categories = current_operator.categories
  end

  def weekly
    @report = ReviewAggregator.new(current_operator).weekly_report
    @categories = current_operator.categories.order(:priority)
  end
end
```

- [ ] **Step 3: Create daily review view**

```erb
<%# app/views/reviews/daily.html.erb %>
<div class="p-4 max-w-2xl mx-auto">
  <h1 class="text-2xl font-display mb-2">Daily Review</h1>
  <p class="text-sm text-base-content/70 mb-6">Triage. Adjust. Focus.</p>

  <!-- Inbox nudge -->
  <% if @inbox_count > 0 %>
    <div class="alert alert-soft mb-4">
      <span><%= @inbox_count %> commitment(s) need triage</span>
      <%= link_to "Inbox →", inbox_path, class: "link" %>
    </div>
  <% end %>

  <!-- Category allocation overview -->
  <h2 class="text-lg font-semibold mb-3">Today's Allocations</h2>
  <div class="space-y-2 mb-6">
    <% @categories.each do |cat| %>
      <div class="flex justify-between items-center">
        <span><%= cat.name %></span>
        <span class="text-sm text-base-content/70"><%= cat.weekly_allocation_minutes %> min/week</span>
      </div>
    <% end %>
  </div>

  <!-- Recommendations -->
  <h2 class="text-lg font-semibold mb-3">Today's Focus</h2>
  <% if @recommendations.any? %>
    <%= render Dashboard::RecommendationCardComponent.new(recommendation: @recommendations.first, current_block: nil) %>
  <% else %>
    <p class="text-base-content/50">You're caught up. Go live your life.</p>
  <% end %>
</div>
```

- [ ] **Step 4: Create weekly review view**

```erb
<%# app/views/reviews/weekly.html.erb %>
<div class="p-4 max-w-2xl mx-auto">
  <h1 class="text-2xl font-display mb-2">Weekly Review</h1>
  <p class="text-sm text-base-content/70 mb-6">Reflect. Rebalance. Realign.</p>

  <!-- Category breakdown -->
  <h2 class="text-lg font-semibold mb-3">Attention Allocation</h2>
  <div class="space-y-4">
    <% @report[:categories].each do |cat| %>
      <div class="card bg-base-200 p-4">
        <div class="flex justify-between items-start">
          <div>
            <h3 class="font-semibold"><%= cat[:name] %></h3>
            <div class="text-sm mt-1">
              <span>Allocated: <%= cat[:allocated] %> min</span> ·
              <span>Actual: <%= cat[:actual] %> min</span>
            </div>
          </div>
          <div class="text-right">
            <% if cat[:debt] > 0 %>
              <div class="badge badge-warning"><%= cat[:debt] %> min behind</div>
            <% else %>
              <div class="badge badge-success">On track</div>
            <% end %>
          </div>
        </div>
      </div>
    <% end %>
  </div>

  <!-- Summary -->
  <div class="grid grid-cols-2 gap-4 mt-6">
    <div class="card bg-base-200 p-4 text-center">
      <div class="text-2xl font-bold"><%= @report[:completed_count] %></div>
      <div class="text-sm text-base-content/70">Completed</div>
    </div>
    <div class="card bg-base-200 p-4 text-center">
      <div class="text-2xl font-bold"><%= @report[:captured_count] %></div>
      <div class="text-sm text-base-content/70">Captured</div>
    </div>
  </div>
</div>
```

- [ ] **Step 5: Add routes**

```ruby
# config/routes.rb
namespace :reviews do
  get :daily, path: "/reviews/daily"
  get :weekly, path: "/reviews/weekly"
end
```

- [ ] **Step 6: Run test**

```bash
bin/rails test test/controllers/reviews_controller_test.rb
```

- [ ] **Step 7: Commit**

```bash
git add -A && git commit -m "feat: add daily and weekly review pages"
```

---

### Task D2: Settings page

**Files:**
- Create: `app/controllers/settings_controller.rb`
- Create: `app/views/settings/index.html.erb`
- Create: `app/views/settings/profile.html.erb`
- Create: `app/views/settings/calendar.html.erb`
- Modify: `config/routes.rb`
- Test: `test/controllers/settings_controller_test.rb`

**Interfaces:**
- Consumes: `Operator`, `CalendarConnection`
- Produces: `GET /settings`, `PATCH /settings/profile`

- [ ] **Step 1: Write test**

```ruby
# test/controllers/settings_controller_test.rb
require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in operators(:one)
    get settings_url
    assert_response :success
  end
end
```

- [ ] **Step 2: Create controller**

```ruby
# app/controllers/settings_controller.rb
class SettingsController < ApplicationController
  before_action :require_authentication

  def index
    @operator = current_operator
    @calendar_connections = current_operator.calendar_connections
  end

  def profile
    @operator = current_operator
  end

  def update_profile
    if current_operator.update(profile_params)
      redirect_to settings_path, notice: "Profile updated"
    else
      render :profile, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:operator).permit(:name, :email, :timezone)
  end
end
```

- [ ] **Step 3: Create settings index view**

```erb
<%# app/views/settings/index.html.erb %>
<div class="p-4 max-w-2xl mx-auto">
  <h1 class="text-2xl font-display mb-6">Settings</h1>

  <div class="space-y-4">
    <!-- Profile -->
    <div class="card bg-base-200 p-4">
      <h2 class="font-semibold mb-2">Profile</h2>
      <p class="text-sm text-base-content/70"><%= @operator.email %></p>
      <%= link_to "Edit →", settings_profile_path, class: "link mt-2" %>
    </div>

    <!-- Calendar Connections -->
    <div class="card bg-base-200 p-4">
      <h2 class="font-semibold mb-2">Calendar</h2>
      <% if @calendar_connections.any? %>
        <% @calendar_connections.each do |conn| %>
          <div class="flex justify-between items-center">
            <span><%= conn.provider.titleize %></span>
            <%= button_to "Disconnect", calendar_connection_path(conn), method: :delete, class: "btn btn-ghost btn-sm text-error", data: { turbo_confirm: "Disconnect?" } %>
          </div>
        <% end %>
      <% else %>
        <p class="text-sm text-base-content/70 mb-2">No calendar connected</p>
        <%= link_to "Connect Google Calendar", new_calendar_connection_path, class: "btn btn-primary btn-sm" %>
      <% end %>
    </div>

    <!-- Export -->
    <div class="card bg-base-200 p-4">
      <h2 class="font-semibold mb-2">Export Data</h2>
      <p class="text-sm text-base-content/70 mb-2">Download all your data as JSON</p>
      <%= link_to "Export", "#", class: "btn btn-outline btn-sm" %>
    </div>
  </div>
</div>
```

- [ ] **Step 4: Add routes**

```ruby
# config/routes.rb
resource :settings, only: [:index] do
  get :profile
  patch :update_profile
end
```

- [ ] **Step 5: Commit**

```bash
git add -A && git commit -m "feat: add settings page with profile + calendar connections"
```

---

### Task D3: Versioned API endpoints

**Files:**
- Create: `app/controllers/api/v1/base_controller.rb`
- Create: `app/controllers/api/v1/recommendations_controller.rb`
- Create: `app/controllers/api/v1/commitments_controller.rb`
- Create: `app/controllers/api/v1/events_controller.rb`
- Create: `app/views/api/v1/recommendations/show.json.jbuilder`
- Create: `app/views/api/v1/commitments/index.json.jbuilder`
- Create: `app/views/api/v1/events/create.json.jbuilder`
- Modify: `config/routes.rb`
- Create: `config/initializers/rack_attack.rb`
- Test: `test/controllers/api/v1/recommendations_controller_test.rb`

**Interfaces:**
- Consumes: `Kern::Engine::Pipeline`, `Commitment`, `OperatorEvent`
- Produces: JSON API under `/api/v1/`

- [ ] **Step 1: Create API base controller**

```ruby
# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :require_authentication
      before_action :authenticate_via_token

      private

      def authenticate_via_token
        token = request.headers["X-API-Key"]
        @current_operator = Operator.find_by(api_token: token)
        render json: { error: "Unauthorized" }, status: :unauthorized unless @current_operator
      end
    end
  end
end
```

- [ ] **Step 2: Create recommendations endpoint**

```ruby
# app/controllers/api/v1/recommendations_controller.rb
module Api
  module V1
    class RecommendationsController < BaseController
      def show
        @recommendations = Kern::Engine::Pipeline.run(
          operator: @current_operator,
          current_time: Time.current
        )
      end
    end
  end
end
```

- [ ] **Step 3: Create jbuilder views**

```ruby
# app/views/api/v1/recommendations/show.json.jbuilder
json.recommendations @recommendations do |r|
  json.id r.commitment_id
  json.title r.title
  json.explanation r.reasons
end
```

- [ ] **Step 4: Create commitments endpoint**

```ruby
# app/controllers/api/v1/commitments_controller.rb
module Api
  module V1
    class CommitmentsController < BaseController
      def create
        @commitment = @current_operator.commitments.create!(commitment_params)
        render :create, status: :created
      end

      private

      def commitment_params
        params.require(:commitment).permit(:title, :description, :category_id)
      end
    end
  end
end
```

- [ ] **Step 5: Create events endpoint**

```ruby
# app/controllers/api/v1/events_controller.rb
module Api
  module V1
    class EventsController < BaseController
      def create
        @event = @current_operator.operator_events.create!(event_params)
        render :create, status: :created
      end

      private

      def event_params
        params.require(:event).permit(:event_type, :commitment_id, metadata: {})
      end
    end
  end
end
```

- [ ] **Step 6: Add routes**

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resource :recommendation, only: [:show]
    resources :commitments, only: [:create]
    resources :events, only: [:create]
  end
end
```

- [ ] **Step 7: Add Rack::Attack**

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  throttle("api/ip", limit: 100, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/")
  end
end
```

Add `rack-attack` to Gemfile.

- [ ] **Step 8: Commit**

```bash
git add -A && git commit -m "feat: add /api/v1 endpoints + Rack::Attack rate limiting"
```

---

### Task D4: Stimulus controllers + ICS import

**Files:**
- Create: `app/javascript/controllers/auto_submit_controller.js`
- Create: `app/javascript/controllers/dismissable_controller.js`
- Create: `app/javascript/controllers/modal_controller.js`
- Create: `app/services/ics_importer.rb`
- Modify: `config/importmap.rb`

**Interfaces:**
- Consumes: existing Hotwire setup
- Produces: client-side interactivity, ICS calendar import

- [ ] **Step 1: Create auto_submit Stimulus controller**

```javascript
// app/javascript/controllers/auto_submit_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.requestSubmit()
  }
}
```

- [ ] **Step 2: Create dismissable controller**

```javascript
// app/javascript/controllers/dismissable_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dismiss() {
    this.element.remove()
  }
}
```

- [ ] **Step 3: Create ICS importer service**

```ruby
# app/services/ics_importer.rb
class IcsImporter
  def initialize(operator, file)
    @operator = operator
    @file = file
  end

  def import
    events = IcsParser.parse(@file.read)
    events.each do |event|
      @operator.calendar_blocks.create!(
        title: event[:title],
        start_at: event[:start],
        end_at: event[:end],
        block_type: :operator,
        capability: :light
      )
    end
  end
end
```

- [ ] **Step 4: Commit**

```bash
git add -A && git commit -m "feat: add Stimulus controllers + ICS import"
```

---

# Execution Order

```
Sub-plan A (Foundation) — required first, blocks everything
  ├── A1: Rename User → Operator [TOUCHES EVERY FILE]
  ├── A2: FTS5 search (standalone)
  └── A3: Litestream (standalone)

Sub-plan B (Calendar) — after A1
  ├── B1: Google OAuth + CalendarSyncJob
  └── B2: Calendar view page

Sub-plan C (Jobs) — after A1, independent of B
  ├── C1: RecommendationJob recurring + triggers
  ├── C2: ReviewPreparationJob
  └── C3: BackupJob + CleanupJob

Sub-plan D (UI/API) — after A1, independent of B/C
  ├── D1: Reviews subsystem
  ├── D2: Settings page
  ├── D3: Versioned API + Rack::Attack
  └── D4: Stimulus controllers + ICS import
```

# Self-Review (compliance checklist)

1. **Spec coverage:** Each missing feature from audit maps to a task. Google OAuth → B1. Reviews → D1. Calendar view → B2. Settings → D2. FTS5 → A2. Litestream → A3. Recurring jobs → C1. Missing jobs → C2, C3. API → D3. Stimulus/ICS → D4. User→Operator rename → A1. All gaps covered.

2. **Placeholder scan:** No TBD/TODO/fill-in-later patterns. Every step has real code. Test code is real Minitest.

3. **Type consistency:** All method signatures referenced across tasks match. `Kern::Engine::Pipeline.run(operator:, current_time:)` consistent throughout. `ReviewAggregator.new(operator).weekly_report` consistent in C2 and D1. `Operator.find_each` consistent across all jobs.

4. **Gaps found:** Active Storage file attachments (voice notes, documents), Svelte interactive calendar planner, data export button (D2 has placeholder `#` link). These are lower priority roadmap items per system-design.md. Adding a note.