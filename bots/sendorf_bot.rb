class SendorfBot < RTanque::Bot::Brain
  NAME = 'Sendorf_bot'
  include RTanque::Bot::BrainHelper

  TURRET_FIRE_RANGE = RTanque::Heading::ONE_DEGREE * 4.0

  def tick!
    ## main logic goes here
    # use self.sensors to detect things
    # use self.command to control tank
    # self.arena contains the dimensions of the arena
    if (lock = self.get_radar_lock)
      if(self.am_i_followed?(lock) or self.sensors.health <= 50.5)
        self.followed_lock(lock)
      else
        self.destroy_lock(lock)
        @desired_heading = nil
      end
    else
      self.move_to_corner
      self.seek_lock
    end
  end

  def move_to_corner
    if self.corner
      command.heading = self.sensors.position.heading(RTanque::Point.new(*self.corner, self.arena))
      command.speed = MAX_BOT_SPEED
    end
  end

  def corner=(corner_name)
    @corner = case corner_name
      when :NE
        [self.arena.width, self.arena.height]
      when :SE
        [self.arena.width, 0]
      when :SW
        [0, 0]
      else
        [0, self.arena.height]
    end
  end

  def corner
    @corner
  end

  def move_to_corner
    if self.corner
      command.heading = self.sensors.position.heading(RTanque::Point.new(*self.corner, self.arena))
      command.speed = MAX_BOT_SPEED
    end
  end

  def corner=(corner_name)
    @corner = case corner_name
      when :NE
        [self.arena.width, self.arena.height]
      when :SE
        [self.arena.width, 0]
      when :SW
        [0, 0]
      else
        [0, self.arena.height]
    end
  end

  def corner
    @corner
  end

  def destroy_lock(reflection)
    command.heading = reflection.heading
    command.radar_heading = reflection.heading
    command.turret_heading = reflection.heading
    command.speed = reflection.distance > 200 ? MAX_BOT_SPEED : MAX_BOT_SPEED / 2.0
    if (reflection.heading.delta(sensors.turret_heading)).abs < TURRET_FIRE_RANGE
      command.fire(reflection.distance > 200 ? MAX_FIRE_POWER : MIN_FIRE_POWER)
    end
  end

  def seek_lock
    if sensors.position.on_wall?
      @desired_heading = sensors.heading + RTanque::Heading::HALF_ANGLE
    end
    command.radar_heading = sensors.radar_heading + MAX_RADAR_ROTATION
    command.speed = 1
    if @desired_heading
      command.heading = @desired_heading
      command.turret_heading = @desired_heading
    end
  end

  def get_radar_lock
    @locked_on ||= nil
    lock = if @locked_on
      sensors.radar.first
    else
      sensors.radar.first
    end
    @locked_on = lock.name if lock
    lock
  end

  def am_i_followed?(reflection)
    sensors.heading == -(reflection.heading)
  end

  def followed_lock(reflection)
    command.heading = RTanque::Heading.new_from_degrees(rand(360))
    command.radar_heading = reflection.heading
    command.turret_heading = reflection.heading
    command.speed = reflection.distance > 200 ? MAX_BOT_SPEED : MAX_BOT_SPEED / 2.0
    if (reflection.heading.delta(sensors.turret_heading)).abs < TURRET_FIRE_RANGE
      command.fire(reflection.distance > 300 ? MAX_FIRE_POWER : MIN_FIRE_POWER)
    end
  end

end
