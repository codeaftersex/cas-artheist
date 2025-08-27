import React, { useState, useEffect } from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { setConfig } from "../slices/configSlice";
import { setLocale } from "../slices/localeSlice";
import { useDispatch, useSelector } from "react-redux";
import { AnimatePresence, motion } from "framer-motion";
import bgMask from "../assets/bgmask.png";
import "../index.css";
import { useVisibility } from "../providers/VisibilityProvider";
import "react-datepicker/dist/react-datepicker.css";
import mainbg from "../assets/bg.png";
import createeventbg from "../assets/createeventbg.png";
import legendarybg from "../assets/legendarybg.png";
import simplebg from "../assets/simplebg.png";
import rarebg from "../assets/rarebg.png";
import manybg from "../assets/manybg.png";
import { fetchNui } from "../utils/fetchNui";
type Offers = {
  label: string;
  minPrice: number;
  maxPrice: number;
  prop : string;
  bg: string;
};

const cardVariants = {
  hidden: { opacity: 0, y: 50, scale: 0.95 },
  visible: (i) => ({
    opacity: 1,
    y: 0,
    scale: 1,
    transition: {
      delay: i * 0.1,
      duration: 0.4,
      ease: "easeOut",
    },
  }),
  exit: { opacity: 0, y: 50, scale: 0.9, transition: { duration: 0.1 } },
};

const StatueOfferImages: Record<string, string> = {
  "p_gen_statue02b": legendarybg,
  "p_cherubstatuenbx01x": rarebg,
  "p_headbust03x": simplebg,
  "p_gen_statue02b_many": manybg,
};



const App: React.FC = () => {
  const { visible, setVisible } = useVisibility();
  const dispatch = useDispatch();
  const locale = useSelector((state: RootState) => state.localeSlice.locale);
  const [offers, setOffers] = useState<Offers[]>([]);
  const [pedName, setPedName] = useState<string>("");
  const [pedDialogText, setPedDialogText] = useState<string>("");
  const [fullText, setFullText] = useState<string>("");
  const [textVersion, setTextVersion] = useState<number>(0);
  
  useNuiEvent("setLocale", (locale: any) => {
    dispatch(setLocale(locale));
    setPedDialogText(locale.defaultWelcomeText);
  });

  useNuiEvent("setDialog", (text: any) => {
    if (!visible) setVisible(true);
    console.log("setDialog", text);
    setFullText(text);
    setTextVersion((v) => v + 1);
  });
  
  useEffect(() => {
    if (!fullText) return;
  
    let currentIndex = 0;
    setPedDialogText("");
  
    const interval = setInterval(() => {
      currentIndex++;
      setPedDialogText(fullText.slice(0, currentIndex));
  
      if (currentIndex >= fullText.length) {
        clearInterval(interval);
      }
    }, 30);
  
    return () => clearInterval(interval);
  }, [textVersion]);
  

  useNuiEvent("setConfig", (config: any) => {
    dispatch(setConfig(config));
  
    const deliveryOffers = config.DeliveryLocations?.[0]?.offers || {};
  
    const offersWithImages = Object.entries(deliveryOffers).map(([prop, data]: [string, any]) => {
      const label = config.Offers?.[prop]?.label || prop;
      const bg = StatueOfferImages[prop];

      return {
        label,
        minPrice: data.minPrice,
        maxPrice: data.maxPrice,
        prop,
        bg: bg || "",
      };
    });
  
    setOffers(offersWithImages);
  });
  
  useNuiEvent("setVisible", (data: any) => {
    setPedName(data.pedName || pedName);
    setVisible(true);
});

  const hideFrame = () => {
    setVisible(false);
    fetchNui("hideFrame", {});
  };



return (
    <div className="w-screen h-screen flex flex-col items-center justify-center">
      <AnimatePresence>
        {visible && (
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.9 }}
            transition={{ duration: 0.4, ease: "easeOut" }}
            className="w-[60%] h-4/5 flex items-center justify-center"
            style={{
              backgroundImage: `url(${bgMask})`,
              backgroundSize: "100% 100%",
            }}
          >
            <div className="w-[90%] h-[85%] flex flex-col items-center">
              <div className="w-3/5 h-[25%] relative flex items-center">
                <div className="flex flex-col">
                  <h1>
                    <span className="text-[#EABA77] text-[17px]">{pedName}</span> - A statue smuggler
                  </h1>
                  <p className="text-[15px]">
                    {pedDialogText}
                  </p>
                </div>
              </div>

              <div className="w-full h-full flex items-center flex-col justify-center">
                <div className="w-5/6 h-[80%] grid grid-cols-2 gap-[5.5556vh]">
                  {offers.map((offer, index) => (
                    <motion.div
                      key={index}
                      custom={index}
                      initial="hidden"
                      animate="visible"
                      exit="exit"
                      variants={cardVariants}
                      className="w-full h-[165px] relative flex items-center justify-center cursor-pointer hover:scale-[1.02] transition-transform"
                      style={{
                        backgroundImage: `url(${offer.bg})`,
                        backgroundSize: "100% 100%",
                      }}
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      onClick={() => {
                        fetchNui("selectOffer", { offer: offer.prop }).then((success) => {
                          if (success) {
                            // hideFrame();
                          }
                        });
                      }}                      
                    >
                      <div className="absolute bottom-2 right-[5%] text-[12px] text-[#ffffff86]">
                        {locale.startfrom} ${offer.minPrice}
                      </div>
                      <div className="flex flex-col items-center justify-center">
                        <h1 className="text-[24px]">{locale.getOffer}</h1>
                        <p className="text-[17px] text-[#ffffffa2]">{offer.label}</p>
                      </div>
                    </motion.div>
                  ))}
                </div>

                <motion.button
                  className="w-2/4 h-[42px] mt-6"
                  style={{
                    backgroundImage: `url(${createeventbg})`,
                    backgroundSize: "100% 100%",
                  }}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={hideFrame}
                >
                  {locale.closemenu}
                </motion.button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
};

export default App;


