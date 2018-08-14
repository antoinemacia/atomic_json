# AtomicJson

Expose a simple set of methods to allow fast atomic updates of `json`/`jsonb` columns of ActiveRecord models using PostgresQL `jsonb_set` [function](https://www.postgresql.org/docs/9.5/static/functions-json.html) 

- Support updates of `json` and `jsonb` columns
- Support update of deeply nested fields
- Support update of multiple fields at once

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'atomic_json'
```

And then execute:

    $ bundle install

## Usage

To update a `json` or `jsonb` column, simply pass a Hash to the bellow method call, 
using the column name as top level key and a nested hash of the value(s) you're willing to update

Only the fields you've specified will be updated

``` 
order.data
=> { amount: 50.00, first_name: 'Milkpie', last_name: 'Starlord' }

order.jsonb_update(data: { amount: 10.00 })

order.data
=> { amount: 10.00, first_name: 'Milkpie', last_name: 'Starlord' }
``` 

For the sake of simplicity, AtomicJson mimic the behavior of standard ActiveRecord query methods to update database fields

### jsonb_update_columns

Same as ActiveRecord `update_columns`, this method will make a straight database update
- Validations are skipped
- Callbacks are skipped
- `updated_at` is not updated

```
order.jsonb_update_columns(data: { paid: false })
=> true
```

### jsonb_update

Same as ActiveRecord `update`, this method will
- Invoke validations
- Invoke callbacks
- Touch record `updated_at`

```
order.jsonb_update(data: { paid: false, product_id: 3772389212 })
=> false
```

### jsonb_update!

Same as the above `json_update!`, but will raise an `ActiveRecord::RecordInvalid` exception 
if a custom validation fails

```
order.jsonb_update!(data: { paid: false, product_id: 3772389212 })
=> ActiveRecord::RecordInvalid Exception: Validation failed: data product_id can't be changed
```
## Todo's

- Support update of `json`/`jsonb` arrays via index and key/value id

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Legsman/atomic_json.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
