Call = Struct.new(
                  # Data needed for creation
                  :arrival_tick,
                  :handle_time,
                  :percentile,

                  # Filled out on initial handling by CB
                  :vh_call_id,
                  :pcwt,
                  :ewt,

                  # Filled out on answer
                  :answered_tick,
                  :punctuality)