proc run_ppo { {num_iters 1} {en_phys_opt 1} } {
  for {set i 0} {$i < $num_iters} {incr i} {
    place_design -post_place_opt
    if {$en_phys_opt != 0} {
      phys_opt_design
    }
    route_design
  }
}

run_ppo 3 1 ; # run 3 post-route iterations and enable phys_opt_design
