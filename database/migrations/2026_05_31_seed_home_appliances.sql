USE home_fundi;

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Dishwasher', 'Kitchen', 'Drainage, water inlet, pump and control faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Dishwasher');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Freezer', 'Kitchen', 'Cooling, thermostat, compressor and seal issues', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Freezer');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Water Dispenser', 'Kitchen', 'Heating, cooling, leakage and pump faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Water Dispenser');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Electric Kettle', 'Kitchen', 'Heating element, switch and power faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Electric Kettle');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Blender', 'Kitchen', 'Motor, blade, jar and switch repairs', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Blender');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Food Processor', 'Kitchen', 'Motor, gear, blade and bowl lock faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Food Processor');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Toaster', 'Kitchen', 'Heating, lever, timer and wiring issues', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Toaster');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Coffee Maker', 'Kitchen', 'Brewing, heating, pump and leakage faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Coffee Maker');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Rice Cooker', 'Kitchen', 'Heating plate, thermostat and switch faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Rice Cooker');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Air Fryer', 'Kitchen', 'Heating element, fan and control board issues', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Air Fryer');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Iron', 'Laundry', 'Heating, thermostat, steam and cable faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Iron');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Dryer', 'Laundry', 'Heating, drum, belt and sensor faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Dryer');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Vacuum Cleaner', 'Cleaning', 'Suction, motor, hose and filter issues', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Vacuum Cleaner');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Water Heater', 'Bathroom', 'Heating element, thermostat and leakage faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Water Heater');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Shower Heater', 'Bathroom', 'Instant shower heating, wiring and pressure faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Shower Heater');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Air Conditioner', 'Climate', 'Cooling, gas refill, fan and compressor issues', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Air Conditioner');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Fan', 'Climate', 'Motor, speed control, blade and oscillation faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Fan');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Heater', 'Climate', 'Heating element, thermostat and power faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Heater');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Sound System', 'Electronics', 'Power, speaker, amplifier and Bluetooth issues', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Sound System');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Home Theatre', 'Electronics', 'Audio, HDMI, power and speaker faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Home Theatre');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Generator', 'Power', 'Starting, fuel, alternator and wiring faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Generator');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Inverter/UPS', 'Power', 'Battery, charging, output and board faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Inverter/UPS');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Solar Water Pump', 'Power', 'Pump, wiring, controller and panel faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Solar Water Pump');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Security Camera/CCTV', 'Security', 'Camera, DVR, wiring and network faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Security Camera/CCTV');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Electric Gate Motor', 'Security', 'Motor, remote, sensor and power faults', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Electric Gate Motor');

INSERT INTO appliances (name, category, description, image_url)
SELECT 'Sewing Machine', 'General', 'Motor, belt, needle timing and pedal issues', ''
WHERE NOT EXISTS (SELECT 1 FROM appliances WHERE name = 'Sewing Machine');
