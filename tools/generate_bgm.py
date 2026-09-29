"""Original 8-bar looping lounge/arcade score, generated without third-party audio."""
import math, wave, array, random
from pathlib import Path
RATE=22050
BEAT=60/84
LENGTH=32*BEAT
N=round(LENGTH*RATE)
left=[0.0]*N
right=[0.0]*N
rng=random.Random(20260929)

def note(midi,start,beats,gain=0.1,pan=0.0,bass=False):
    freq=440*2**((midi-69)/12)
    duration=beats*BEAT
    offset=round(start*BEAT*RATE)
    for i in range(round(duration*RATE)):
        t=i/RATE
        env=min(1,t/.014)*math.exp(-t/(duration*.28))
        tone=math.sin(math.tau*freq*t)
        if not bass: tone+=.22*math.sin(math.tau*freq*2*t)+.07*math.sin(math.tau*freq*3*t)
        value=tone*env*gain
        j=(offset+i)%N
        left[j]+=value*(1-pan*.4)
        right[j]+=value*(1+pan*.4)

chords=[[50,57,61,66],[47,54,57,62],[43,50,54,59],[45,52,57,61]]
for bar in range(8):
    chord=chords[bar%4]
    for k,pitch in enumerate(chord):note(pitch+12,bar*4+k*.06,4,.047,(k-1.5)/2)
    note(chord[0]-12,bar*4,1.7,.09,bass=True)
    note(chord[0]-12,bar*4+2.5,1.2,.06,bass=True)
melody=[(0,78),(1.5,73),(3,69),(4.5,74),(6,78),(7,76),(8.5,74),(10,71),(11.5,69),(12.5,73),(14,76),(15.5,73)]
for repeat in [0,16]:
    for beat,pitch in melody:note(pitch,beat+repeat,1.8,.052,.25)
for beat in range(32):
    offset=round(beat*BEAT*RATE)
    for i in range(round(.11*RATE)):
        t=i/RATE
        kick=math.sin(math.tau*(52*t+3*(1-math.exp(-t*25))))*math.exp(-t*45)*.032 if beat%2==0 else 0
        hat=rng.uniform(-1,1)*math.exp(-t*95)*.009
        j=(offset+i)%N
        left[j]+=kick+hat;right[j]+=kick-hat
samples=array.array('h')
for l,r in zip(left,right):
    samples.extend([round(max(-.9,min(.9,l))*32767),round(max(-.9,min(.9,r))*32767)])
Path('assets/audio').mkdir(parents=True,exist_ok=True)
with wave.open('assets/audio/slow-afternoon.wav','wb') as f:
    f.setnchannels(2);f.setsampwidth(2);f.setframerate(RATE);f.writeframes(samples.tobytes())
print('Original seamless BGM:',round(LENGTH,2),'seconds, 84 BPM')
