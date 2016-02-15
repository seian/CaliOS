int main() {
    int i=0;
    char *video = (char *)0xB800;
    for(i=0;i<80*25*2;i++) {
        video[i] = 'H';
        video[i+1] = 0x4A;
    
    }
    return 0;
}
