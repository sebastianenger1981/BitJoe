package de.hgnut.Misc;
import java.io.IOException;
import java.io.InputStream;
public class GZIPInputStream extends InputStream{

    public GZIPInputStream(InputStream inputstream, int i1)
    throws IOException {
        _fldvoid = new byte[1];
        J = 32768;
        af = 32767;
        ap = new byte[32768];
        v = inputstream;
        a(true);
        W = 0;
        if(i1 <= 0)
        {
            throw new IOException("size <= 0");
        } else
        {
            x = new byte[i1];
            return;
        }
    }

    public GZIPInputStream(InputStream inputstream)
    throws IOException{
        this(inputstream, 512);
    }

    public int read(byte abyte0[], int i1, int j1)
        throws IOException
    {
        if(!y)
            _mthnull();
        if(l)
            return -1;
        j1 = _mthfor(abyte0, i1, j1);
        if(_mthbyte())
            _mthchar();
        return j1;
    }

    public int read()
        throws IOException
    {
        return read(_fldvoid, 0, 1) != -1 ? _fldvoid[0] & 0xff : -1;
    }

    public int read(byte abyte0[])
        throws IOException
    {
        return read(abyte0, 0, abyte0.length);
    }

    public void close()
        throws IOException
    {
        v.close();
    }

    public long skip(long l1)
        throws IOException
    {
        if(l1 < 0L)
            throw new IOException("negative skip length");
        byte abyte0[] = new byte[512];
        long l2 = 0L;
        do
        {
            if(l2 >= l1)
                break;
            long l3 = l1 - l2;
            l3 = read(abyte0, 0, l3 >= (long)abyte0.length ? abyte0.length : (int)l3);
            if(l3 == -1L)
            {
                l = true;
                break;
            }
            l2 += l3;
        } while(true);
        return l2;
    }

    public int available()
        throws IOException
    {
        return _mthbyte() ? 0 : 1;
    }

    public synchronized void mark(int i1)
    {
        v.mark(i1);
    }

    public synchronized void reset()
        throws IOException
    {
        v.reset();
    }

    public boolean markSupported()
    {
        return v.markSupported();
    }

    private void _mthnull()
        throws IOException
    {
        int k2;
label0:
        {
            int i1 = v.read();
            if(i1 < 0)
            {
                l = true;
                return;
            }
            int j1 = v.read();
            if(i1 != U[0] || j1 != U[1])
                throw new IOException("Not in GZIP format");
            int j2 = v.read();
            k2 = v.read();
            if(j2 != 8 || (k2 & 0xe0) != 0)
                throw new IOException("Corrupt GZIP header");
            for(int l2 = 0; l2 < 6; l2++)
                if(v.read() < 0)
                    throw new IOException("Corrupt GZIP header");

            if((k2 & 4) == 0)
                break label0;
            int i3 = v.read();
            if(i3 < 0)
                throw new IOException("Corrupt GZIP header");
            int k1 = v.read();
            if(k1 < 0)
                throw new IOException("Corrupt GZIP header");
            i3 += k1 << 8;
            do
            {
                if(i3-- == 0)
                    break label0;
                k1 = v.read();
            } while(k1 >= 0);
            throw new IOException("Corrupt GZIP header");
        }
        int l1;
        if((k2 & 8) != 0)
            while((l1 = v.read()) != 0) 
                if(l1 < 0)
                    throw new IOException("Corrupt GZIP header");
        if((k2 & 0x10) != 0)
            while((l1 = v.read()) != 0) 
                if(l1 < 0)
                    throw new IOException("Corrupt GZIP header");
        if((k2 & 2) != 0)
        {
            for(int j3 = 0; j3 < 2; j3++)
            {
                int i2 = v.read();
                if(i2 < 0)
                    throw new IOException("Corrupt GZIP header");
            }

        }
        y = true;
    }

    private void _mthchar()
        throws IOException
    {
        byte abyte0[] = new byte[8];
        int j1 = _mthcase();
        if(j1 > 8)
            j1 = 8;
        System.arraycopy(x, W - _mthcase(), abyte0, 0, j1);
        int l1;
        for(int k1 = 8 - j1; k1 > 0; k1 -= l1)
        {
            l1 = v.read(abyte0, 8 - k1, k1);
            if(l1 <= 0)
                throw new IOException("Corrupt GZIP trailer");
        }

        int i1 = abyte0[4] & 0xff | (abyte0[5] & 0xff) << 8 | (abyte0[6] & 0xff) << 16 | abyte0[7] << 24;
        if(i1 != a())
        {
            throw new IOException("Corrupt GZIP trailer");
        } else
        {
            l = true;
            return;
        }
    }

    private int _mthfor(byte abyte0[], int i1, int j1)
        throws IOException
    {
        do
        {
            do
            {
                int k1 = _mthdo(abyte0, i1, j1);
                if(k1 > 0)
                    return k1;
                if(_mthlong() || _mthbyte())
                    return -1;
            } while(_fldgoto != _fldint);
            _mthif();
        } while(true);
    }

    private int _mthcase()
    {
        return (_fldint - _fldgoto) + (K >> 3);
    }

    private int _mthnew()
    {
        return al - _mthcase();
    }

    private int _mthtry()
    {
        return _mthlong() ? o : D;
    }

    protected void _mthif()
        throws IOException
    {
        int i1 = 0;
        W = v.read(x, i1, x.length);
        if(W < 0)
            throw new IOException("Unexpected end of ZLIB input stream");
        if(_fldgoto < _fldint)
            throw new IOException("Internal State Error");
        int j1 = i1 + W;
        if(0 > i1 || i1 > j1 || j1 > x.length)
            throw new IOException("Internal State Error");
        if((W & 1) != 0)
        {
            G |= (x[i1++] & 0xff) << K;
            K += 8;
        }
        aA = x;
        _fldgoto = i1;
        _fldint = j1;
        al += W;
    }

    private boolean _mthlong()
    {
        return T == 1 && C == 0;
    }

    private boolean _mthbyte()
    {
        return T == 12 && _fldcase == 0;
    }

    private int a()
    {
        return at;
    }

    private final int _mthdo(int i1)
    {
        if(K < i1)
        {
            if(_fldgoto == _fldint)
                return -1;
            G |= (aA[_fldgoto++] & 0xff | (aA[_fldgoto++] & 0xff) << 8) << K;
            K += 16;
        }
        return G & (1 << i1) - 1;
    }

    private final void _mthif(int i1)
    {
        G >>>= i1;
        K -= i1;
    }

    private void _mthdo()
    {
        G >>= K & 7;
        K &= -8;
    }

    private int a(byte abyte0[], int i1, int j1)
    {
        if(j1 < 0)
            return -1;
        if((K & 7) != 0)
            return -1;
        int k1;
        for(k1 = 0; K > 0 && j1 > 0; k1++)
        {
            abyte0[i1++] = (byte)G;
            G >>>= 8;
            K -= 8;
            j1--;
        }

        if(j1 == 0)
            return k1;
        int l1 = _fldint - _fldgoto;
        if(j1 > l1)
            j1 = l1;
        System.arraycopy(aA, _fldgoto, abyte0, i1, j1);
        _fldgoto += j1;
        if((_fldgoto - _fldint & 1) != 0)
        {
            G = aA[_fldgoto++] & 0xff;
            K = 8;
        }
        return k1 + j1;
    }

    private void a(boolean flag)
    {
        A = flag;
        T = flag ? 2 : 0;
        al = at = 0;
        _fldgoto = _fldint = 0;
        G = K = 0;
        _fldcase = av = 0;
        _fldtry = null;
        r = null;
        H = false;
        D = 1;
    }

    private int _mthdo(byte abyte0[], int i1, int j1)
        throws IOException
    {
        int i3 = 0;
        if(j1 == 0)
            return 0;
        if(0 > i1 || i1 > i1 + j1 || i1 + j1 > abyte0.length)
            throw new IOException("Internal State Error");
        int l2 = 0;
        do
        {
            if(T != 11)
            {
                int k2 = i1;
                int l1 = av;
                int k1 = j1;
                if(k1 > _fldcase)
                    k1 = _fldcase;
                else
                    l1 = (av - _fldcase) + k1 & 0x7fff;
                int j2 = k1;
                int i2 = k1 - l1;
                if(i2 > 0)
                {
                    System.arraycopy(ap, 32768 - i2, abyte0, k2, i2);
                    k2 += i2;
                    k1 = l1;
                }
                System.arraycopy(ap, l1 - k1, abyte0, k2, k1);
                _fldcase -= j2;
                if(_fldcase < 0)
                    throw new IOException("Internal State Error");
                _mthif(abyte0, i1, j2);
                i1 += j2;
                l2 += j2;
                at += j2;
                j1 -= j2;
                if(j1 == 0)
                    return l2;
            }
            i3 = _mthfor();
            if(i3 < 0)
                throw new IOException("Internal State Error");
        } while(i3 == 1 || _fldcase > 0 && T != 11);
        return l2;
    }

    private static final short a(int i1)
    {
        return (short)(j[i1 & 0xf] << 12 | j[i1 >> 4 & 0xf] << 8 | j[i1 >> 8 & 0xf] << 4 | j[i1 >> 12]);
    }

    private static short[] a(byte abyte0[], int i1)
    {
        int ai1[] = new int[16];
        int ai2[] = new int[16];
        for(int l3 = 0; l3 <= 15; l3++)
            ai1[l3] = 0;

        for(int i3 = 0; i3 < i1; i3++)
            ai1[abyte0[i3]]++;

        int j2 = 0;
        int j1 = 512;
        for(int i4 = 1; i4 <= 15; i4++)
        {
            ai2[i4] = j2;
            j2 += ai1[i4] << 16 - i4;
            if(i4 > 9)
            {
                int k4 = j2 & 0xfff80;
                int i5 = ai2[i4] & 0xfff80;
                j1 += k4 - i5 >> 16 - i4;
            }
        }

        short aword0[] = new short[j1];
        if(aword0 == null)
            return aword0;
        int k1 = 512;
        for(int j4 = 15; j4 > 9; j4--)
        {
            int l4 = j2 & 0xfff80;
            j2 -= ai1[j4] << 16 - j4;
            int j5 = j2 & 0xfff80;
            for(int j3 = j5; j3 < l4; j3 += 128)
            {
                aword0[a(j3)] = (short)(-k1 << 4 | j4);
                k1 += 1 << j4 - 9;
            }

        }

        for(int k3 = 0; k3 < i1; k3++)
        {
            byte byte0 = abyte0[k3];
            if(byte0 == 0)
                continue;
            int k2 = ai2[byte0];
            int l2 = a(k2);
            if(byte0 <= 9)
            {
                do
                {
                    aword0[l2] = (short)(k3 << 4 | byte0);
                    l2 += 1 << byte0;
                } while(l2 < 512);
            } else
            {
                int l1 = aword0[l2 & 0x1ff];
                int i2 = 1 << (l1 & 0xf);
                l1 = -(l1 >> 4);
                do
                {
                    aword0[l1 | l2 >> 9] = (short)(k3 << 4 | byte0);
                    l2 += 1 << byte0;
                } while(l2 < i2);
            }
            ai2[byte0] = k2 + (1 << 16 - byte0);
        }

        return aword0;
    }

    private int a(short aword0[])
    {
        int l1 = _mthdo(9);
        if(l1 < 0)
        {
            int j1 = K;
            l1 = _mthdo(j1);
            short word0 = aword0[l1];
            if(word0 >= 0 && (word0 & 0xf) <= j1)
            {
                _mthif(word0 & 0xf);
                return word0 >> 4;
            } else
            {
                return -1;
            }
        }
        short word1;
        if((word1 = aword0[l1]) >= 0)
        {
            _mthif(word1 & 0xf);
            return word1 >> 4;
        }
        int i1 = -(word1 >> 4);
        int k1 = word1 & 0xf;
        if((l1 = _mthdo(k1)) >= 0)
        {
            word1 = aword0[i1 | l1 >> 9];
            _mthif(word1 & 0xf);
            return word1 >> 4;
        }
        k1 = K;
        l1 = _mthdo(k1);
        word1 = aword0[i1 | l1 >> 9];
        if((word1 & 0xf) <= k1)
        {
            _mthif(word1 & 0xf);
            return word1 >> 4;
        } else
        {
            return -1;
        }
    }

    private int _mthfor()
    {
        switch(T)
        {
        case 0: // '\0'
            int i1 = _mthdo(16);
            if(i1 < 0)
                return 0;
            _mthif(16);
            i1 = (i1 << 8 | i1 >> 8) & 0xffff;
            if(i1 % 31 != 0)
                return -3;
            if((i1 & 0xf00) != 2048)
                return -3;
            if((i1 & 0x20) == 0)
            {
                T = 2;
            } else
            {
                T = 1;
                C = 32;
            }
            return 1;

        case 1: // '\001'
            for(; C > 0; C -= 8)
            {
                int j1 = _mthdo(8);
                if(j1 < 0)
                    return 0;
                _mthif(8);
                o = o << 8 | j1;
            }

            return 0;

        case 2: // '\002'
            if(H)
                if(A)
                {
                    T = 12;
                    return 0;
                } else
                {
                    T = 11;
                    return 1;
                }
            int k1 = _mthdo(3);
            if(k1 < 0)
                return 0;
            _mthif(3);
            if((k1 & 1) != 0)
                H = true;
            switch(k1 >> 1)
            {
            case 0: // '\0'
                _mthdo();
                T = 3;
                break;

            case 1: // '\001'
                _fldtry = q;
                r = t;
                T = 7;
                break;

            case 2: // '\002'
                _mthelse();
                T = 6;
                break;

            default:
                return -3;
            }
            return 1;

        case 3: // '\003'
            if((aa = _mthdo(16)) < 0)
                return 0;
            _mthif(16);
            T = 4;
            // fall through

        case 4: // '\004'
            int l1 = _mthdo(16);
            if(l1 < 0)
                return 0;
            _mthif(16);
            if(l1 != (aa ^ 0xffff))
                return -3;
            T = 5;
            // fall through

        case 5: // '\005'
            int l2 = Math.min(Math.min(aa, 32768 - _fldcase), _mthcase());
            int i3 = 0;
            boolean flag = false;
            int i4 = 32768 - av;
            if(l2 > i4)
            {
                int j3 = a(ap, av, i4);
                if(j3 < 0)
                    return -3;
                i3 = j3;
                if(i3 == i4)
                {
                    int k3 = a(ap, 0, l2 - i4);
                    if(k3 < 0)
                        return -3;
                    i3 += k3;
                }
            } else
            {
                int l3 = a(ap, av, l2);
                if(l3 < 0)
                    return -3;
                i3 = l3;
            }
            av = av + i3 & 0x7fff;
            _fldcase += i3;
            aa -= i3;
            if(aa == 0)
            {
                T = 2;
                return 1;
            } else
            {
                return _fldgoto == _fldint ? 0 : 1;
            }

        case 6: // '\006'
            int i2 = _mthint();
            if(i2 == 0)
                return 0;
            if(i2 == -1)
                return -3;
            T = 7;
            // fall through

        case 7: // '\007'
        case 8: // '\b'
        case 9: // '\t'
        case 10: // '\n'
            int j2 = _mthgoto();
            if(j2 == 0)
                return 0;
            return j2 != 1 ? -3 : 1;

        case 11: // '\013'
            _mthdo();
            for(C = 32; C > 0; C -= 8)
            {
                int k2 = _mthdo(8);
                if(k2 < 0)
                    return 0;
                _mthif(8);
                o = o << 8 | k2;
            }

            if(D != o)
            {
                return -3;
            } else
            {
                T = 12;
                return 0;
            }

        case 12: // '\f'
            return 0;

        default:
            return -3;
        }
    }

    private int _mthgoto()
    {
        int j2 = 32768 - _fldcase;
        do
        {
            if(j2 < 258)
                break;
            switch(T)
            {
            case 7: // '\007'
                int i1;
                while(((i1 = a(_fldtry)) & 0xffffff00) == 0) 
                {
                    if(_fldcase++ == 32768)
                        return -1;
                    ap[av++] = (byte)i1;
                    av &= 0x7fff;
                    if(--j2 < 258)
                        return 1;
                }
                if(i1 < 0)
                    return 0;
                if(i1 == 256)
                {
                    r = null;
                    _fldtry = null;
                    T = 2;
                    return 1;
                }
                int k1 = i1 - 257;
                if(k1 < 0 || k1 > 30)
                    return -1;
                ab = M[k1];
                C = as[k1];
                // fall through

            case 8: // '\b'
                if(C > 0)
                {
                    T = 8;
                    int l1 = _mthdo(C);
                    if(l1 < 0)
                        return 0;
                    _mthif(C);
                    ab += l1;
                }
                T = 9;
                // fall through

            case 9: // '\t'
                int j1 = a(r);
                if(j1 < 0)
                    return 0;
                if(j1 < 0 || j1 > 29)
                    return -1;
                I = u[j1];
                C = ad[j1];
                // fall through

            case 10: // '\n'
                if(C > 0)
                {
                    T = 10;
                    int i2 = _mthdo(C);
                    if(i2 < 0)
                        return 0;
                    _mthif(C);
                    I += i2;
                }
                if((_fldcase += ab) > 32768)
                    return -1;
                int k2 = av - I & 0x7fff;
                int l2 = ab;
                int i3 = 32768 - ab;
                if(k2 <= i3 && av < i3)
                {
                    if(l2 <= I)
                    {
                        System.arraycopy(ap, k2, ap, av, l2);
                        av += l2;
                    } else
                    {
                        while(l2-- > 0) 
                            ap[av++] = ap[k2++];
                    }
                } else
                {
                    while(l2-- > 0) 
                    {
                        ap[av++] = ap[k2++];
                        av &= 0x7fff;
                        k2 &= 0x7fff;
                    }
                }
                j2 -= ab;
                T = 7;
                break;

            default:
                return -1;
            }
        } while(true);
        return 1;
    }

    private void _mthelse()
    {
        S = 0;
        ac = z = V = aC = 0;
        ao = 0;
        aw = 0;
        _fldchar = 0;
    }

    private int _mthint()
    {
label0:
        do
            switch(S)
            {
            default:
                break;

            case 0: // '\0'
                ac = _mthdo(5);
                if(ac < 0)
                    return 0;
                ac += 257;
                _mthif(5);
                S = 1;
                // fall through

            case 1: // '\001'
                z = _mthdo(5);
                if(z < 0)
                    return 0;
                z++;
                _mthif(5);
                aC = ac + z;
                au = new byte[aC];
                S = 2;
                // fall through

            case 2: // '\002'
                V = _mthdo(4);
                if(V < 0)
                    return 0;
                V += 4;
                _mthif(4);
                s = new byte[19];
                _fldchar = 0;
                S = 3;
                // fall through

            case 3: // '\003'
                for(; _fldchar < V; _fldchar++)
                {
                    int i1 = _mthdo(3);
                    if(i1 < 0)
                        return 0;
                    _mthif(3);
                    s[ax[_fldchar]] = (byte)i1;
                }

                Z = a(s, s.length);
                s = null;
                _fldchar = 0;
                S = 4;
                // fall through

            case 4: // '\004'
                int j1;
                while(((j1 = a(Z)) & 0xfffffff0) == 0) 
                {
                    au[_fldchar++] = aw = (byte)j1;
                    if(_fldchar == aC)
                        break label0;
                }
                if(j1 < 0)
                    return 0;
                if(j1 >= 17)
                    aw = 0;
                else
                if(_fldchar == 0)
                    return -1;
                ao = j1 - 16;
                S = 5;
                // fall through

            case 5: // '\005'
                int k1 = c[ao];
                int l1 = _mthdo(k1);
                if(l1 < 0)
                    return 0;
                _mthif(k1);
                l1 += X[ao];
                if(_fldchar + l1 > aC)
                    return -1;
                while(l1-- > 0) 
                    au[_fldchar++] = aw;
                if(_fldchar == aC)
                    break label0;
                S = 4;
                break;
            }
        while(true);
        byte abyte0[] = new byte[ac];
        System.arraycopy(au, 0, abyte0, 0, ac);
        _fldtry = a(abyte0, ac);
        abyte0 = new byte[z];
        System.arraycopy(au, ac, abyte0, 0, z);
        r = a(abyte0, z);
        return 1;
    }

    private void _mthif(byte abyte0[], int i1, int j1)
    {
        int k1 = D & 0xffff;
        int l1 = D >> 16 & 0xffff;
        for(int i2 = 0; i2 < j1; i2++)
        {
            k1 = (k1 + abyte0[i2]) % 65521;
            l1 = (l1 + k1) % 65521;
        }

        D = (l1 << 16) + k1;
    }

    protected InputStream v;
    protected byte x[];
    protected int W;
    protected boolean l;
    private byte _fldvoid[];
    private static final String L = "Not in GZIP format";
    private static final String E = "Unsupported compression method";
    private static final String am = "Corrupt GZIP header";
    private static final String _fldnew = "Corrupt GZIP trailer";
    private static final String _fldnull = "Internal State Error";
    private static final int U[] = {
        31, 139
    };
    private static final int Q = 1;
    private static final int w = 2;
    private static final int F = 4;
    private static final int O = 8;
    private static final int Y = 16;
    private static final int ah = 224;
    private boolean y;
    private static final int f = 0;
    private static final int m = 1;
    private static final int d = 2;
    private static final int h = -3;
    private static final int B = -4;
    private static final int _fldbyte = -5;
    private static final int ag = -6;
    private byte aA[];
    private int _fldgoto;
    private int _fldint;
    private int al;
    private int aa;
    private int T;
    private boolean H;
    private boolean A;
    private int o;
    private int at;
    private int C;
    private final int J;
    private final int af;
    private byte ap[];
    private int av;
    private int _fldcase;
    private int G;
    private int K;
    private static short q[];
    private static short t[];
    private short _fldtry[];
    private short r[];
    private int ab;
    private int I;
    private static final int M[] = {
        3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 
        15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 
        67, 83, 99, 115, 131, 163, 195, 227, 258, 0, 
        0
    };
    private static final int as[] = {
        0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 
        1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 
        4, 4, 4, 4, 5, 5, 5, 5, 0, 112, 
        112
    };
    private static final int u[] = {
        1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 
        33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 
        1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577
    };
    private static final int ad[] = {
        0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 
        4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 
        9, 9, 10, 10, 11, 11, 12, 12, 13, 13
    };
    private static final short j[] = {
        0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 
        5, 13, 3, 11, 7, 15
    };
    private static final int n = 15;
    private static final int ay = 7;
    private static final int ae = 0xfff80;
    private static final int _fldlong = 9;
    private static final int N = 512;
    private static final int P = 8;
    private static final int ai = 0;
    private static final int g = 1;
    private static final int _fldelse = 2;
    private static final int _fldfor = 3;
    private static final int aB = 4;
    private static final int ak = 5;
    private static final int b = 6;
    private static final int _fldif = 7;
    private static final int az = 8;
    private static final int R = 9;
    private static final int ar = 10;
    private static final int aj = 11;
    private static final int p = 12;
    private static final int _flddo = 13;
    private static final int k = 0;
    private static final int a = 1;
    private static final int i = 2;
    private static final int aq = 3;
    private static final int e = 4;
    private static final int aD = 5;
    private static final int X[] = {
        3, 3, 11
    };
    private static final int c[] = {
        2, 3, 7
    };
    private static final int ax[] = {
        16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 
        11, 4, 12, 3, 13, 2, 14, 1, 15
    };
    private int S;
    private int ac;
    private int z;
    private int V;
    private int aC;
    private int ao;
    private byte aw;
    private int _fldchar;
    private byte s[];
    private byte au[];
    private short Z[];
    private static final int an = 65521;
    private int D;

    static 
    {
        byte abyte0[] = new byte[288];
        int i1;
        for(i1 = 0; i1 < 144;)
            abyte0[i1++] = 8;

        while(i1 < 256) 
            abyte0[i1++] = 9;
        while(i1 < 280) 
            abyte0[i1++] = 7;
        while(i1 < 288) 
            abyte0[i1++] = 8;
        q = a(abyte0, 288);
        abyte0 = new byte[32];
        for(int j1 = 0; j1 < 32;)
            abyte0[j1++] = 5;

        t = a(abyte0, 32);
    }
}