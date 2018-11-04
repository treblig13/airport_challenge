require 'airport'

describe Airport do

  let(:airport) { Airport.new }

  describe "#initialize" do
    it 'creates an empty hangar when initialized' do
      expect(airport.hangar).to eq []
    end

    it 'creates a weather system when initialized' do
      expect(airport.weather).to be_a_kind_of WeatherSystem
    end

    it 'it has a default capacity' do
      expect(airport.capacity).to eq Airport::DEFAULT_CAPACITY
    end

    it 'allows a user to set a capacity' do
      airport = Airport.new(10)
      expect(airport.capacity).to eq 10
    end
  end

  describe '#land' do
    context 'whilst no storm is present' do
      it 'allows a plane to land at an airport' do
        allow(airport).to receive(:weather_check).and_return('Sunshine')
        plane = Plane.new
        airport.land(plane)
        expect(airport.hangar).to eq [plane]
      end

      it 'raises an error if a plane that has landed attempts to land' do
        allow(airport).to receive(:weather_check).and_return('Sunshine')
        plane = Plane.new
        airport.land(plane)
        expect { airport.land(plane) }.to raise_error 'Plane has already landed!'
      end

      it 'raises an error when a plane that has already landed at another airport is asked to land' do
        allow(airport).to receive(:weather_check).and_return('Sunshine')
        airport_2 = Airport.new
        allow(airport_2).to receive(:weather_check).and_return('Sunshine')
        plane = Plane.new
        airport.land(plane)
        expect { airport_2.land(plane) }.to raise_error 'Plane has already at another airport!'
      end

      it 'raises an error when attempting to land a plane when the airport is full having set a default capacity' do
        allow(airport).to receive(:weather_check).and_return('Sunshine')
        Airport::DEFAULT_CAPACITY.times { airport.land(Plane.new) }
        expect { airport.land(Plane.new) }.to raise_error 'Unable to land when airport full!'
      end

      it 'raises an error when atempting to land a plane when the airport is full having set a custom capacity' do
        custom_airport = Airport.new(3)
        allow(custom_airport).to receive(:weather_check).and_return('Sunshine')
        3.times { custom_airport.land(Plane.new) }
        expect { custom_airport.land(Plane.new) }.to raise_error 'Unable to land when airport full!'
      end
    end

    context 'during a storm' do
      it 'raises an error when a plane tries to land during a storm' do
        allow(airport).to receive(:weather_check).and_return('Stormy')
        plane = Plane.new
        expect { airport.land(plane) }.to raise_error 'Plane cannot land during storm!'
      end
    end
  end

  describe '#plane_take_off' do
    context 'when no storm is present' do
      it 'allows planes to take off from an airport' do
        allow(airport).to receive(:weather_check).and_return('Sunshine')
        plane = Plane.new
        airport.land(plane)
        airport.take_off(plane)
        expect(airport.hangar).to be_empty
      end

      it 'raises an error when there are no planes left at the airport' do
        allow(airport).to receive(:weather_check).and_return('Sunshine')
        plane = Plane.new
        expect { airport.take_off(plane) }.to raise_error 'There are no planes left at this airport!'
      end

      it 'raises an error when the requested plane to take off is not at the airport' do
        allow(airport).to receive(:weather_check).and_return('Sunshine')
        plane = Plane.new
        plane2 = Plane.new
        airport.land(plane)
        expect { airport.take_off(plane2) }.to raise_error 'That plane is not at the airport!'
      end
    end

    context 'during a storm' do
      it 'raises an error when a plane attempts to take off during a storm' do
        allow(airport).to receive(:weather_check).and_return('Sunshine')
        plane = Plane.new
        airport.land(plane)
        allow(airport).to receive(:weather_check).and_return('Stormy')
        expect { airport.take_off(plane) }.to raise_error 'Plane cannot take off during storm!'
      end
    end
  end

  describe '#confirm_take_off' do
    it 'allows user to confirm a plane has taken off' do
      allow(airport).to receive(:weather_check).and_return('Sunshine')
      plane = Plane.new
      airport.land(plane)
      airport.take_off(plane)
      expect(airport.confirm_take_off(plane)).to eq "Confirmed: #{plane} has taken off!"
    end

    it 'raises an error if the plane has not taken off' do
      allow(airport).to receive(:weather_check).and_return('Sunshine')
      plane = Plane.new
      airport.land(plane)
      expect { airport.confirm_take_off(plane) }.to raise_error "#{plane} has not taken off!"
    end
  end

  describe '#weather_check' do
    it 'allows user to check the weather' do
      expect(airport.weather_check).to eq('Sunshine').or eq('Stormy')
    end
  end

end
