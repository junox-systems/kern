# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Only seed if no categories exist for the first operator (idempotent)
operator = Operator.first
return unless operator
return if operator.categories.any?

puts "Seeding Kern for #{operator.name}..."

# Categories — areas of life with weekly allocations
work = operator.categories.create!(
  name: "Work",
  description: "Professional commitments and projects",
  priority: 1,
  weekly_allocation_minutes: 1200  # 20 hours
)

health = operator.categories.create!(
  name: "Health",
  description: "Exercise, medical, wellness",
  priority: 2,
  weekly_allocation_minutes: 420   # 7 hours
)

learning = operator.categories.create!(
  name: "Learning",
  description: "Reading, courses, exploration",
  priority: 3,
  weekly_allocation_minutes: 300   # 5 hours
)

relationships = operator.categories.create!(
  name: "Relationships",
  description: "Family, friends, community",
  priority: 4,
  weekly_allocation_minutes: 360   # 6 hours
)

maintenance = operator.categories.create!(
  name: "Maintenance",
  description: "Admin, errands, logistics",
  priority: 5,
  weekly_allocation_minutes: 180   # 3 hours
)

# Calendar — create a default Kern calendar
calendar = operator.calendars.create!(name: "Kern")

# Calendar blocks — today's schedule
today = Date.current

calendar.calendar_blocks.create!(
  operator: operator,
  category: work,
  capability: :deep,
  date: today,
  start_time: "09:00",
  end_time: "12:00",
  block_type: :manual
)

calendar.calendar_blocks.create!(
  operator: operator,
  category: maintenance,
  capability: :admin,
  date: today,
  start_time: "12:00",
  end_time: "13:00",
  block_type: :manual
)

calendar.calendar_blocks.create!(
  operator: operator,
  category: work,
  capability: :deep,
  date: today,
  start_time: "14:00",
  end_time: "17:00",
  block_type: :manual
)

calendar.calendar_blocks.create!(
  operator: operator,
  category: health,
  capability: :physical,
  date: today,
  start_time: "18:00",
  end_time: "19:00",
  block_type: :manual
)

calendar.calendar_blocks.create!(
  operator: operator,
  category: learning,
  capability: :light,
  date: today,
  start_time: "21:00",
  end_time: "22:00",
  block_type: :manual
)

# Commitments — a realistic set
operator.commitments.create!(
  title: "Write proposal for client project",
  description: "Draft the technical proposal for the new engagement",
  category: work,
  capability: :deep,
  estimate_minutes: 90,
  due_at: 1.day.from_now,
  state: :ready
)

operator.commitments.create!(
  title: "Review architecture design",
  description: "Review and provide feedback on the system architecture",
  category: work,
  capability: :deep,
  estimate_minutes: 60,
  due_at: 3.days.from_now,
  state: :ready
)

operator.commitments.create!(
  title: "Exercise",
  description: "30-minute run or gym session",
  category: health,
  capability: :physical,
  estimate_minutes: 45,
  state: :ready
)

operator.commitments.create!(
  title: "Read research paper",
  description: "Read and take notes on the distributed systems paper",
  category: learning,
  capability: :light,
  estimate_minutes: 40,
  due_at: 5.days.from_now,
  state: :ready
)

operator.commitments.create!(
  title: "Call mother",
  category: relationships,
  capability: :social,
  estimate_minutes: 30,
  state: :ready
)

operator.commitments.create!(
  title: "Pay electricity bill",
  category: maintenance,
  capability: :admin,
  estimate_minutes: 10,
  due_at: 2.days.from_now,
  state: :ready
)

operator.commitments.create!(
  title: "Buy groceries",
  category: maintenance,
  capability: :physical,
  estimate_minutes: 45,
  state: :ready
)

# Inbox items — uncategorized captures
operator.commitments.create!(title: "Look into new database options", state: :inbox)
operator.commitments.create!(title: "Schedule dentist appointment", state: :inbox)
operator.commitments.create!(title: "Reply to Sarah's email", state: :inbox)

puts "Seeded: #{operator.categories.count} categories, #{operator.commitments.count} commitments, #{operator.calendar_blocks.count} blocks"
