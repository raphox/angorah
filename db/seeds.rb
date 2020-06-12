USERS = [
  { first_name: 'Vinnie', last_name: 'Lintott', website: 'http://indiatimes.com' },
  { first_name: 'Otha', last_name: 'Kunes', website: 'https://edublogs.org' },
  { first_name: 'Dayle', last_name: 'Caswill', website: 'http://sohu.com' },
  { first_name: 'Erastus', last_name: 'Quilligan', website: 'http://skyrock.com' },
  { first_name: 'Jamal', last_name: 'Cullington', website: 'https://webmd.com' },
  { first_name: 'Joice', last_name: 'Brooke', website: 'http://marketwatch.com' },
  { first_name: 'Gwenni', last_name: 'Dines', website: 'http://typepad.com' },
  { first_name: 'Glyn', last_name: 'Clouter', website: 'https://google.ru' },
  { first_name: 'Lucienne', last_name: 'Ready', website: 'http://myspace.com' },
  { first_name: 'Katuscha', last_name: 'Tinman', website: 'http://umn.edu' },
]

USERS.each do |attributes|
  User.create(attributes)
  UserNeo4j.create(attributes)
end
