class Seeder
  def seed_admins
    seeding "admins"
    clear_table "admins"
    admin = Admin.new({
        :first_name => "admin",
        :last_name => "admin",
        :email => ENV["email_contact"].dup, # Dup to avoid a Devise error…
        :admin => true,
    })
    admin.password = admin.password_confirmation = random_string
    #admin.confirm!
    say "admin: #{admin.email} => #{admin.password}"
    admin.save!
  end

private
  def random_string(length = 16)
    a = [(0..9), ('a'..'z'), ('A'..'Z')].map { |x| x.to_a }.flatten
    (0...length).map { a[rand(a.length)] }.join
  end
end

